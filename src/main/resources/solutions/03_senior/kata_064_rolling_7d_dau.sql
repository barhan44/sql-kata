-- =============================================================================
-- KATA 064 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Сначала получаем уникальные пары user_id/login_date: повторные логины
--     не должны увеличивать DAU.
--   • Календарь покрывает весь отчётный период, включая дни без логинов.
--   • Для каждого дня join берёт логины за [day - 6, day]. Один пользователь
--     с несколькими датами в окне появляется несколько раз, но
--     COUNT(DISTINCT user_id) считает его один раз.
--   • daily_active_users считается через FILTER только для текущего дня,
--     rolling_7d_users — по всему семидневному диапазону.
--   • COUNT(DISTINCT ...) нельзя применить как оконную функцию в PostgreSQL;
--     календарный join — стандартное и предсказуемое решение.
--   • Partial index user_events_login_time_idx ускоряет чтение login-событий,
--     а user_events(user_id, occurred_at) помогает разрежению дат.
-- =============================================================================

WITH days AS (
    SELECT generate_series(
        TIMESTAMP '2024-05-01 00:00:00',
        TIMESTAMP '2024-06-30 00:00:00',
        INTERVAL '1 day'
    )::date AS activity_date
),
daily_logins AS (
    SELECT DISTINCT
        user_id,
        occurred_at::date AS login_date
    FROM user_events
    WHERE event_type = 'login'
)
SELECT
    d.activity_date,
    count(DISTINCT l.user_id) FILTER (
        WHERE l.login_date = d.activity_date
    ) AS daily_active_users,
    count(DISTINCT l.user_id) AS rolling_7d_users
FROM days d
LEFT JOIN daily_logins l
       ON l.login_date BETWEEN d.activity_date - 6 AND d.activity_date
GROUP BY d.activity_date
ORDER BY d.activity_date ASC;
