-- =============================================================================
-- KATA 087 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Self-join order_items по order_id даёт пары товаров из одного заказа.
--   • Условие a.product_id < b.product_id:
--       – убирает зеркальную пару (B,A) после (A,B);
--       – убирает пару товара с самим собой;
--       – делает направление пары детерминированным.
--   • COUNT(DISTINCT order_id) не учитывает дубли, если в будущем в заказе
--     появится несколько строк одного товара.
--   • JOIN products дважды нужен только для имён; фильтр по delivered стоит
--     до агрегации и сокращает объём.
--   • Индексы order_items(order_id), order_items(product_id) и
--     orders(status, created_at) помогают соединению. На очень больших данных
--     self-join квадратичен внутри заказа; часто ограничивают Top-N парами.
-- =============================================================================

SELECT
    a.product_id AS product_a_id,
    pa.name AS product_a_name,
    b.product_id AS product_b_id,
    pb.name AS product_b_name,
    count(DISTINCT a.order_id) AS orders_together
FROM order_items a
JOIN order_items b
  ON b.order_id = a.order_id
 AND a.product_id < b.product_id
JOIN orders o ON o.order_id = a.order_id
JOIN products pa ON pa.product_id = a.product_id
JOIN products pb ON pb.product_id = b.product_id
WHERE o.status = 'delivered'
GROUP BY a.product_id, pa.name, b.product_id, pb.name
ORDER BY orders_together DESC, product_a_id ASC, product_b_id ASC;
