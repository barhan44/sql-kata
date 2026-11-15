-- =============================================================================
-- KATA 032 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Агрегация и оконные функции разделены на два уровня: сначала получаем
--     выручку по каждому товару, затем добавляем к ней суммы по категории
--     и по всему магазину.
--   • PARTITION BY category_id в SUM даёт знаменатель доли категории,
--     пустое окно SUM() OVER () — общую выручку магазина.
--   • 100.0 переводит вычисление в numeric; NULLIF защищает деление,
--     хотя здесь суммы положительны.
--   • INNER JOIN с categories исключает товары без категории, что
--     соответствует условию.
--   • Индексы order_items(order_id), order_items(product_id) и
--     orders(status, created_at) помогают выполнить соединения и фильтр.
-- =============================================================================

WITH product_revenue AS (
    SELECT
        c.category_id,
        c.name AS category_name,
        p.product_id,
        p.name AS product_name,
        sum(oi.line_total) AS product_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN categories c ON c.category_id = p.category_id
    WHERE o.status = 'delivered'
    GROUP BY c.category_id, c.name, p.product_id, p.name
),
with_totals AS (
    SELECT
        category_name,
        product_id,
        product_name,
        product_revenue,
        sum(product_revenue) OVER (PARTITION BY category_id) AS category_revenue,
        sum(product_revenue) OVER () AS store_revenue
    FROM product_revenue
)
SELECT
    category_name,
    product_id,
    product_name,
    product_revenue,
    category_revenue,
    store_revenue,
    round(100.0 * product_revenue / NULLIF(category_revenue, 0), 2) AS category_share_pct,
    round(100.0 * product_revenue / NULLIF(store_revenue, 0), 2) AS store_share_pct
FROM with_totals
ORDER BY category_name ASC, product_revenue DESC, product_id ASC;
