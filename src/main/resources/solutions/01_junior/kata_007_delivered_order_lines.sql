-- =============================================================================
-- KATA 007 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • INNER JOIN безопасен: order_items.order_id и product_id объявлены
--     NOT NULL с внешними ключами.
--   • line_total — реальная STORED generated column, поэтому фильтр по ней
--     не требует повторного вычисления суммы со скидкой и соответствует
--     данным, зафиксированным на момент заказа.
--   • Фильтр по status заказа стоит после соединения, но PostgreSQL может
--     применить его до JOIN и сократить объём работы.
--   • Индексы order_items(order_id), order_items(product_id) и
--     orders(status, created_at) помогают планировщику.
--   • Сортировка только по order_id/product_id достаточна для уникальности:
--     в одном заказе товар не повторяется (UNIQUE).
-- =============================================================================

SELECT
    oi.order_id,
    oi.product_id,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'delivered'
  AND oi.line_total > 5000
ORDER BY oi.order_id ASC, oi.product_id ASC;
