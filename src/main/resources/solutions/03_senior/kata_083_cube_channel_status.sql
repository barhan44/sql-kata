-- =============================================================================
-- KATA 083 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • CUBE(channel, customer_status) — это все 4 комбинации измерений:
--     (channel,status), (channel), (status), ().
--     GROUPING SETS дал бы только перечисленные наборы, ROLLUP — только
--     иерархические; CUBE полезен именно для полного перебора.
--   • channel выводится из promo_code; NULL означает organic-трафик.
--     Это преобразование до группировки, иначе NULL promocode стал бы
--     отдельной группой 'unknown' без бизнес-смысла.
--   • CASE + GROUPING дают явную метку 'ALL', не смешивая итог с реальными
--     значениями.
--   • COUNT(*) считает заказы, поскольку CTE delivered содержит одну строку
--     на заказ. Если бы join размножал строки, понадобился бы DISTINCT.
--   • Сортировка по GROUPING() ставит детали, затем частные и общий итог.
-- =============================================================================

WITH delivered AS (
    SELECT
        COALESCE(o.promo_code, 'organic')::text AS channel,
        u.status::text AS customer_status,
        o.order_id,
        o.total_amount
    FROM orders o
    JOIN users u ON u.user_id = o.user_id
    WHERE o.status = 'delivered'
)
SELECT
    CASE
        WHEN GROUPING(channel) = 1 THEN 'ALL'
        ELSE channel
    END AS channel_display,
    CASE
        WHEN GROUPING(customer_status) = 1 THEN 'ALL'
        ELSE customer_status
    END AS status_display,
    count(*) AS orders_count,
    sum(total_amount) AS revenue,
    GROUPING(channel) = 1 AS is_channel_total,
    GROUPING(customer_status) = 1 AS is_status_total
FROM delivered
GROUP BY CUBE (channel, customer_status)
ORDER BY is_channel_total ASC,
         is_status_total ASC,
         channel_display ASC,
         status_display ASC;
