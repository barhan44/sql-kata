-- =============================================================================
-- KATA 051 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • generate_series создаёт независимую ось дат. Календарь не зависит от
--     наличия заказов, поэтому пропуски не исчезают.
--   • Используем timestamp БЕЗ time zone и шаг INTERVAL '1 day': приведение
--     к date не сдвигает день из-за часового пояса сессии.
--   • Условие o.status = 'delivered' находится в ON. В WHERE оно отфильтровало
--     бы NULL-строки LEFT JOIN и оставило только дни с продажами.
--   • COUNT(o.order_id) считает только совпавшие заказы и возвращает 0 для
--     дней без продаж. SUM при отсутствии строк даёт NULL, поэтому нужен
--     COALESCE(..., 0::numeric).
--   • created_at::date зависит от TimeZone сессии; для отчёта в конкретной
--     бизнес-зоне лучше заранее вычислить дату через AT TIME ZONE.
-- =============================================================================

WITH calendar AS (
    SELECT generate_series(
        TIMESTAMP '2024-06-01 00:00:00',
        TIMESTAMP '2024-06-30 00:00:00',
        INTERVAL '1 day'
    )::date AS sale_date
)
SELECT
    c.sale_date,
    count(o.order_id) AS orders_count,
    COALESCE(sum(o.total_amount), 0::numeric) AS revenue
FROM calendar c
LEFT JOIN orders o
       ON o.created_at::date = c.sale_date
      AND o.status = 'delivered'
GROUP BY c.sale_date
ORDER BY c.sale_date ASC;
