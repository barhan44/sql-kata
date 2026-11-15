-- =============================================================================
-- KATA 042 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Pivot строится без tablefunc: четыре SUM(...) FILTER (...) образуют
--     квартальные колонки, а GROUP BY — строки год/категория.
--   • EXTRACT(QUARTER FROM timestamptz) вычисляется в часовом поясе сессии.
--     Для отчёта с жёсткой бизнес-зоной явно используйте
--     created_at AT TIME ZONE 'Europe/Moscow'; тестовые даты не пересекают
--     границу квартала.
--   • COALESCE(..., 0::numeric) важен: SUM по пустому кварталу возвращает NULL,
--     а бизнес-отчёт ожидает 0.
--   • total_revenue можно посчитать отдельным SUM без фильтра. Он равен сумме
--     квартальных колонок, но не требует складывать их вручную.
--   • Индексы orders(status, created_at), order_items(order_id) и
--     order_items(product_id) помогают соединению и фильтрации.
-- =============================================================================

SELECT
    extract(year FROM o.created_at)::integer AS year,
    c.name AS category_name,
    COALESCE(
        sum(oi.line_total) FILTER (
            WHERE extract(quarter FROM o.created_at) = 1
        ),
        0::numeric
    ) AS q1_revenue,
    COALESCE(
        sum(oi.line_total) FILTER (
            WHERE extract(quarter FROM o.created_at) = 2
        ),
        0::numeric
    ) AS q2_revenue,
    COALESCE(
        sum(oi.line_total) FILTER (
            WHERE extract(quarter FROM o.created_at) = 3
        ),
        0::numeric
    ) AS q3_revenue,
    COALESCE(
        sum(oi.line_total) FILTER (
            WHERE extract(quarter FROM o.created_at) = 4
        ),
        0::numeric
    ) AS q4_revenue,
    sum(oi.line_total) AS total_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status = 'delivered'
GROUP BY extract(year FROM o.created_at), c.category_id, c.name
ORDER BY year ASC, category_name ASC;
