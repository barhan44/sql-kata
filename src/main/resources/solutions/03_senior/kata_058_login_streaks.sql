-- =============================================================================
-- KATA 058 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • daily_logins убирает несколько логинов одного дня через DISTINCT.
--   • Классический gaps-and-islands: у непрерывной последовательности дат
--     разность login_date - row_number() постоянна. После разрыва она меняется,
--     поэтому эта разность служит ключом острова.
--   • row_number() приведён к integer: date - integer = date, получаем
--     стабильный ключ типа date.
--   • HAVING/внешний фильтр оставляет только серии от 3 дней.
--   • Индекс user_events(user_id, occurred_at) и partial index по login
--     помогают отфильтровать события до сортировки.
-- =============================================================================

WITH daily_logins AS (
    SELECT DISTINCT
        user_id,
        occurred_at::date AS login_date
    FROM user_events
    WHERE event_type = 'login'
),
numbered AS (
    SELECT
        user_id,
        login_date,
        login_date - row_number() OVER (
            PARTITION BY user_id
            ORDER BY login_date
        )::integer AS island_key
    FROM daily_logins
),
islands AS (
    SELECT
        user_id,
        min(login_date) AS streak_start,
        max(login_date) AS streak_end,
        count(*) AS streak_days
    FROM numbered
    GROUP BY user_id, island_key
)
SELECT
    i.user_id,
    u.full_name,
    i.streak_start,
    i.streak_end,
    i.streak_days
FROM islands i
JOIN users u ON u.user_id = i.user_id
WHERE i.streak_days >= 3
ORDER BY i.user_id ASC, i.streak_start ASC;
