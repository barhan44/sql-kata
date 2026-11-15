-- =============================================================================
-- KATA 041 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • LAG по бизнес-ключу находит предыдущее событие в пределах раздела.
--     Порядок occurred_at + log_id детерминирован даже при одинаковых метках.
--   • Фильтр occurred_at - previous_at <= INTERVAL '1 minute' оставляет
--     только повторные строки, а не исходное событие.
--   • Если три события пришли подряд в пределах минуты, LAG для третьего
--     укажет на второе; оно тоже будет помечено как дубликат. Для строгого
--     поиска именно оригинала можно взять FIRST_VALUE или дополнительно
--     развернуть цепочку.
--   • EXTRACT(EPOCH FROM interval) даёт секунды; ::integer подходит, поскольку
--     в аудит-событиях секундная точность. Для дробных интервалов используйте
--     numeric с ROUND.
--   • PARTITION BY включает actor_user_id IS NULL: PostgreSQL считает NULL
--     равными для целей оконной группировки. Для системных событий это
--     ожидаемое поведение.
--   • Индекс audit_logs(actor_user_id, occurred_at) помогает при большом
--     объёме, хотя окно по четырём колонкам всё равно потребует сортировки.
-- =============================================================================

WITH ordered_events AS (
    SELECT
        log_id,
        actor_user_id,
        entity_type,
        entity_id,
        action,
        occurred_at,
        lag(log_id) OVER w AS original_log_id,
        lag(occurred_at) OVER w AS previous_occurred_at
    FROM audit_logs
    WINDOW w AS (
        PARTITION BY actor_user_id, entity_type, entity_id, action
        ORDER BY occurred_at, log_id
    )
)
SELECT
    log_id AS duplicate_log_id,
    original_log_id,
    actor_user_id,
    entity_type,
    entity_id,
    action,
    occurred_at,
    extract(epoch FROM (occurred_at - previous_occurred_at))::integer
        AS seconds_after_original
FROM ordered_events
WHERE previous_occurred_at IS NOT NULL
  AND occurred_at - previous_occurred_at <= INTERVAL '1 minute'
ORDER BY log_id ASC;
