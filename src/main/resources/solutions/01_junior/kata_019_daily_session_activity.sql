-- =============================================================================
-- KATA 019 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • started_at::date приводит timestamptz к дате в часовом поясе сессии.
--     Для продакшн-отчёта часовой пояс лучше задать явно
--     (started_at AT TIME ZONE 'Europe/Moscow')::date, чтобы отчёт не менялся
--     вместе с настройками подключения. В учебной базе данные и так
--     не пересекают границу суток в UTC.
--   • Каждый SUM(CASE ...) — отдельный счётчик; ELSE 0 гарантирует, что
--     в группе будет число, а не NULL.
--   • Сумма трёх условных счётчиков равна total_sessions, потому что
--     CHECK-ограничение допускает только три значения device_type.
--   • GROUP BY 1 и ORDER BY session_date опираются на псевдоним результата.
-- =============================================================================

SELECT
    started_at::date AS session_date,
    sum(CASE WHEN device_type = 'desktop' THEN 1 ELSE 0 END) AS desktop_sessions,
    sum(CASE WHEN device_type = 'mobile'  THEN 1 ELSE 0 END) AS mobile_sessions,
    sum(CASE WHEN device_type = 'tablet'  THEN 1 ELSE 0 END) AS tablet_sessions,
    count(*) AS total_sessions
FROM user_sessions
GROUP BY 1
ORDER BY session_date ASC;
