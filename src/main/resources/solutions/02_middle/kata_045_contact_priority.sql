-- =============================================================================
-- KATA 045 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • CASE переводит бизнес-статусы в числовой приоритет. Это позволяет
--     сортировать их одним ORDER BY и явно фиксирует порядок доверия.
--   • DISTINCT ON (user_id) оставляет одну строку на клиента. ORDER BY
--     обязан начинаться с user_id, затем идёт priority, свежесть и contact_id.
--   • updated_at DESC выбирает более новую запись при равном статусе;
--     contact_id DESC снимает последнюю неопределённость.
--   • INNER JOIN с users нужен для отображения имени и сознательно исключает
--     пользователей без кандидатов.
--   • Альтернатива на ROW_NUMBER более переносима и позволила бы, например,
--     вернуть Top-2 контакта, но здесь достаточно одного лучшего.
--   • Индекс user_contact_candidates(user_id, updated_at DESC) помогает
--     выбрать кандидатов, однако сортировка по CASE-приоритету всё равно
--     выполняется планировщиком.
-- =============================================================================

WITH prioritized AS (
    SELECT
        c.contact_id,
        c.user_id,
        u.full_name,
        c.source,
        c.status,
        c.email,
        c.phone,
        c.updated_at,
        CASE c.status
            WHEN 'verified' THEN 1
            WHEN 'pending'  THEN 2
            WHEN 'stale'    THEN 3
            WHEN 'invalid'  THEN 4
            ELSE 5
        END AS priority
    FROM user_contact_candidates c
    JOIN users u ON u.user_id = c.user_id
)
SELECT DISTINCT ON (user_id)
    user_id,
    full_name,
    contact_id,
    source,
    status,
    email,
    phone,
    updated_at
FROM prioritized
ORDER BY user_id ASC, priority ASC, updated_at DESC, contact_id DESC;
