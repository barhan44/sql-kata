-- =============================================================================
-- KATA 016 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • COUNT(conversion_order_id) считает только NOT NULL значения, что
--     идеально соответствует определению конверсии.
--   • NULLIF(COUNT(*), 0) превращает нулевой знаменатель в NULL. В PostgreSQL
--     x / NULL = NULL, а не ошибка; ROUND(NULL) = NULL. Так отчёт останется
--     корректным, даже если в группе не окажется сессий.
--   • 100.0 — numeric-литерал; он переводит всё деление в точную десятичную
--     арифметику. 100 (integer) тоже сработал бы из-за numeric COUNT, но
--     литерал с точкой явнее показывает намерение.
--   • GROUP BY по device_type использует индекс sessions_device_idx.
-- =============================================================================

SELECT
    device_type,
    count(*) AS sessions_count,
    count(conversion_order_id) AS conversions,
    round(
        100.0 * count(conversion_order_id) / NULLIF(count(*), 0),
        2
    ) AS conversion_pct
FROM user_sessions
GROUP BY device_type
ORDER BY device_type ASC;
