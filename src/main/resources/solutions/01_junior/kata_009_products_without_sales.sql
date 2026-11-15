-- =============================================================================
-- KATA 009 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Каждый товар LEFT JOIN-ится со всеми своими позициями в заказах.
--     Товары без позиций получают NULL в oi.order_item_id и проходят фильтр.
--   • Второй LEFT JOIN нужен для категории: у товара с category_id IS NULL
--     category_name тоже должен быть NULL.
--   • Категория не участвует в фильтрации, поэтому LEFT JOIN, а не INNER.
--   • product_id — первичный ключ категории, поэтому дублирования строк
--     из-за соединения с categories нет. Соединение с order_items до фильтра
--     может дать много строк для продаваемых товаров; anti-join через
--     NOT EXISTS на больших данных часто эффективнее, но здесь фиксированный
--     небольшой объём, а LEFT JOIN нагляднее для Junior-уровня.
-- =============================================================================

SELECT
    p.product_id,
    p.name,
    p.price,
    p.is_active,
    c.name AS category_name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN categories c ON c.category_id = p.category_id
WHERE oi.order_item_id IS NULL
ORDER BY p.product_id ASC;
