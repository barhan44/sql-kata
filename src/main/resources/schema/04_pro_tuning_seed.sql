-- =============================================================================
-- SQL KATA · Данные и индексы для уровня Pro & Performance Tuning
--
-- Загружается после 01_init_schema.sql, 02_middle_seed.sql, 03_senior_seed.sql.
-- 20 000 событий нужны, чтобы планировщик всерьёз рассматривал индексы.
-- Скрипт аддитивный: существующие таблицы не меняются.
-- =============================================================================

CREATE TABLE events_big (
    event_id     bigint PRIMARY KEY,
    user_id      integer NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    merchant_id  integer NOT NULL,
    status       text NOT NULL CHECK (
        status IN ('NEW', 'PAID', 'SHIPPED', 'FAILED', 'PROCESSING',
                   'DELIVERED', 'CANCELLED')
    ),
    event_type   text NOT NULL,
    currency     char(3) NOT NULL,
    amount       numeric(12, 2) NOT NULL CHECK (amount > 0),
    created_at   timestamptz NOT NULL,
    retry_count  integer NOT NULL CHECK (retry_count >= 0),
    email        text NOT NULL,
    description  text NOT NULL,
    metadata     jsonb NOT NULL CHECK (jsonb_typeof(metadata) = 'object'),
    search_vector tsvector NOT NULL
);

WITH generated AS (
    SELECT
        g,
        CASE g % 10
            WHEN 0 THEN 'NEW'
            WHEN 1 THEN 'NEW'
            WHEN 2 THEN 'PAID'
            WHEN 3 THEN 'PAID'
            WHEN 4 THEN 'SHIPPED'
            WHEN 5 THEN 'FAILED'
            WHEN 6 THEN 'PROCESSING'
            WHEN 7 THEN 'DELIVERED'
            WHEN 8 THEN 'CANCELLED'
            ELSE 'NEW'
        END AS status,
        CASE
            WHEN g % 97 = 0 THEN 'PAYMENT'
            WHEN g % 89 = 0 THEN 'REFUND'
            WHEN g % 5 = 0 THEN 'LOGIN'
            ELSE 'VIEW'
        END AS event_type,
        CASE g % 3
            WHEN 0 THEN 'USD'
            WHEN 1 THEN 'EUR'
            ELSE 'RUB'
        END::char(3) AS currency,
        (g % 1000) * 500.00 + 0.25 AS amount,
        TIMESTAMPTZ '2025-01-01 00:00:00+03'
            + make_interval(
                days => (g % 365)::integer,
                hours => (g % 24)::integer,
                mins => (g % 60)::integer
              ) AS created_at,
        g % 4 AS retry_count,
        CASE
            WHEN g = 12345 THEN 'Target.User@Example.com'
            ELSE 'User' || lpad(g::text, 5, '0') || '@Example.com'
        END AS email,
        CASE
            WHEN g % 100 = 5 THEN 'payment failed with timeout error'
            WHEN g % 10 = 2 THEN 'payment completed successfully'
            ELSE 'routine activity record'
        END AS description
    FROM generate_series(1, 20000) AS s(g)
)
INSERT INTO events_big (
    event_id,
    user_id,
    merchant_id,
    status,
    event_type,
    currency,
    amount,
    created_at,
    retry_count,
    email,
    description,
    metadata,
    search_vector
)
SELECT
    g,
    ((g - 1) % 25) + 1,
    (g % 97) + 1,
    status,
    event_type,
    currency,
    amount,
    created_at,
    retry_count,
    email,
    description,
    jsonb_build_object(
        'type', CASE
                    WHEN g % 5 IN (0, 2) THEN 'PAYMENT'
                    WHEN g % 5 = 1 THEN 'REFUND'
                    ELSE 'LOGIN'
                END,
        'currency', currency,
        'channel', CASE g % 3 WHEN 0 THEN 'web' WHEN 1 THEN 'mobile' ELSE 'api' END,
        'attempt', g % 3
    ),
    to_tsvector('simple', description)
FROM generated;

CREATE INDEX events_big_created_at_idx
    ON events_big (created_at);
CREATE INDEX events_big_lower_email_idx
    ON events_big (lower(email));
CREATE INDEX events_big_email_pattern_idx
    ON events_big (email text_pattern_ops);
CREATE INDEX events_big_amount_idx
    ON events_big (amount);
CREATE INDEX events_big_status_created_idx
    ON events_big (status, created_at);
CREATE INDEX events_big_covering_idx
    ON events_big (status, created_at) INCLUDE (event_type, amount);
CREATE INDEX events_big_new_retry_partial_idx
    ON events_big (created_at, event_id)
    WHERE status = 'NEW' AND retry_count < 3;
CREATE INDEX events_big_metadata_gin_idx
    ON events_big USING gin (metadata);
CREATE INDEX events_big_search_gin_idx
    ON events_big USING gin (search_vector);
CREATE INDEX events_big_user_idx
    ON events_big (user_id);
CREATE INDEX events_big_merchant_idx
    ON events_big (merchant_id);
CREATE INDEX events_big_user_status_idx
    ON events_big (user_id, status);
CREATE INDEX events_big_merchant_status_idx
    ON events_big (merchant_id, status);
CREATE INDEX events_big_event_type_user_idx
    ON events_big (event_type, user_id);
CREATE INDEX events_big_merchant_status_created_idx
    ON events_big (merchant_id, status, created_at) INCLUDE (amount, event_id);

ANALYZE events_big;
-- Visibility map нужен для честного Index Only Scan в kata_095.
VACUUM (ANALYZE) events_big;

-- -----------------------------------------------------------------------------
-- Support tickets: вторая 1-to-Many ветка для kata_103 и kata_110
-- -----------------------------------------------------------------------------
CREATE TABLE support_tickets (
    ticket_id  integer PRIMARY KEY,
    user_id    integer NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    status     text NOT NULL CHECK (status IN ('OPEN', 'PENDING', 'CLOSED')),
    priority   text NOT NULL CHECK (priority IN ('LOW', 'NORMAL', 'HIGH')),
    created_at timestamptz NOT NULL
);

INSERT INTO support_tickets (ticket_id, user_id, status, priority, created_at)
SELECT
    g,
    ((g - 1) % 25) + 1,
    CASE g % 4 WHEN 0 THEN 'OPEN' WHEN 1 THEN 'PENDING' ELSE 'CLOSED' END,
    CASE g % 3 WHEN 0 THEN 'HIGH' WHEN 1 THEN 'NORMAL' ELSE 'LOW' END,
    TIMESTAMPTZ '2025-01-01 09:00:00+03'
        + make_interval(days => (g % 120)::integer)
FROM generate_series(1, 200) AS s(g);

CREATE INDEX support_tickets_user_idx ON support_tickets (user_id);
ANALYZE support_tickets;

-- -----------------------------------------------------------------------------
-- Очередь задач для конкурентного FOR UPDATE SKIP LOCKED
-- -----------------------------------------------------------------------------
CREATE TABLE task_queue (
    task_id     integer PRIMARY KEY,
    task_type   text NOT NULL,
    status      text NOT NULL CHECK (
        status IN ('NEW', 'PROCESSING', 'DONE', 'FAILED')
    ),
    retry_count integer NOT NULL DEFAULT 0 CHECK (retry_count >= 0),
    payload     jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at  timestamptz NOT NULL
);

INSERT INTO task_queue (task_id, task_type, status, retry_count, payload, created_at)
SELECT
    g,
    CASE g % 3 WHEN 0 THEN 'email' WHEN 1 THEN 'payment' ELSE 'sync' END,
    'NEW',
    0,
    jsonb_build_object('task_id', g),
    TIMESTAMPTZ '2025-06-01 08:00:00+03'
        + make_interval(secs => g)
FROM generate_series(1, 60) AS s(g);

CREATE INDEX task_queue_pending_idx
    ON task_queue (task_id)
    WHERE status = 'NEW';
ANALYZE task_queue;

-- -----------------------------------------------------------------------------
-- Идемпотентные вебхуки
-- -----------------------------------------------------------------------------
CREATE TABLE webhook_events (
    event_id    text PRIMARY KEY,
    event_type  text NOT NULL,
    payload     jsonb NOT NULL,
    received_at timestamptz NOT NULL
);

INSERT INTO webhook_events (event_id, event_type, payload, received_at) VALUES
    ('evt-existing-001', 'PAYMENT_SUCCEEDED', '{"amount":100}', '2025-06-01 10:00:00+03'),
    ('evt-existing-002', 'PAYMENT_FAILED',    '{"amount":200}', '2025-06-01 10:05:00+03'),
    ('evt-existing-003', 'REFUND_ISSUED',      '{"amount":50}',  '2025-06-01 10:10:00+03'),
    ('evt-existing-004', 'PAYMENT_SUCCEEDED', '{"amount":300}', '2025-06-01 10:15:00+03'),
    ('evt-existing-005', 'PAYMENT_SUCCEEDED', '{"amount":400}', '2025-06-01 10:20:00+03'),
    ('evt-existing-006', 'PAYMENT_FAILED',    '{"amount":500}', '2025-06-01 10:25:00+03'),
    ('evt-existing-007', 'REFUND_ISSUED',      '{"amount":60}',  '2025-06-01 10:30:00+03'),
    ('evt-existing-008', 'PAYMENT_SUCCEEDED', '{"amount":700}', '2025-06-01 10:35:00+03'),
    ('evt-existing-009', 'PAYMENT_SUCCEEDED', '{"amount":800}', '2025-06-01 10:40:00+03'),
    ('evt-existing-010', 'PAYMENT_FAILED',    '{"amount":900}', '2025-06-01 10:45:00+03');

-- -----------------------------------------------------------------------------
-- Счета для оптимистичной блокировки
-- -----------------------------------------------------------------------------
CREATE TABLE ledger_accounts (
    account_id integer PRIMARY KEY,
    user_id    integer NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    balance    numeric(14, 2) NOT NULL CHECK (balance >= 0),
    version    bigint NOT NULL CHECK (version >= 0)
);

INSERT INTO ledger_accounts (account_id, user_id, balance, version) VALUES
    (1, 1, 1000.00, 1),
    (2, 2, 2500.00, 4),
    (3, 5, 300.00, 2),
    (4, 9, 10000.00, 7),
    (5, 11, 0.00, 1);

ANALYZE ledger_accounts;
ANALYZE webhook_events;
