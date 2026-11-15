-- =============================================================================
-- KATA 044 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Сначала считаем стоимость заказа в разрезе категории. Один заказ может
--     содержать товары разных категорий, поэтому нельзя использовать общий
--     total_amount для каждой категории без искажения.
--   • PERCENTILE_CONT — интервальный перцентиль из ordered-set агрегатов.
--     В отличие от PERCENTILE_DISC, он интерполирует значение между соседними
--     строками, поэтому медиана может быть дробной.
--   • percentile_cont для числовых данных работает с double precision;
--     явный ::double precision убирает неоднозначность, а результат приводим
--     обратно к numeric перед ROUND(...,2).
--   • GROUP BY по категории после CTE не смешивает строки заказов.
--   • Индексы order_items(order_id) и order_items(product_id) ускоряют
--     соединение; фильтр по статусу использует orders.
-- =============================================================================

WITH category_order_values AS (
    SELECT
        c.category_id,
        c.name AS category_name,
        o.order_id,
        sum(oi.line_total) AS category_order_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN categories c ON c.category_id = p.category_id
    WHERE o.status = 'delivered'
    GROUP BY c.category_id, c.name, o.order_id
)
SELECT
    category_name,
    count(*) AS orders_count,
    round(
        percentile_cont(0.5) WITHIN GROUP (
            ORDER BY category_order_value::double precision
        )::numeric,
        2
    ) AS median_category_order_value,
    round(
        percentile_cont(0.95) WITHIN GROUP (
            ORDER BY category_order_value::double precision
        )::numeric,
        2
    ) AS p95_category_order_value
FROM category_order_values
GROUP BY category_id, category_name
ORDER BY category_name ASC;
