-- =============================================================================
-- KATA 013 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Цепочка INNER JOIN: каждая позиция доставленного заказа имеет товар
--     и категорию. Товары без категории в отчёт по категориям
--     не попадут — это ожидаемое поведение отчёта.
--   • COUNT(DISTINCT o.order_id) не даёт посчитать один заказ дважды, если
--     в нём несколько единиц товаров одной категории.
--   • SUM по quantity возвращает bigint (сумма integer), SUM(line_total) —
--     numeric, поэтому типы соответствуют контракту.
--   • Индексы order_items(order_id), order_items(product_id) и
--     orders(status, created_at) помогают соединению.
--   • Сортировка revenue DESC + name ASC детерминирована.
-- =============================================================================

SELECT
    c.name AS category_name,
    count(DISTINCT o.order_id) AS orders_count,
    sum(oi.quantity) AS units_sold,
    sum(oi.line_total) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status = 'delivered'
GROUP BY c.category_id, c.name
ORDER BY revenue DESC, category_name ASC;
