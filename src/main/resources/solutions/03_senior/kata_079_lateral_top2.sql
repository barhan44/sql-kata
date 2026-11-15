-- =============================================================================
-- KATA 079 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • CROSS JOIN LATERAL позволяет подзапросу ссылаться на внешнюю категорию.
--     Для каждой категории PostgreSQL выполняет Top-2 по индексу/сортировке.
--   • LIMIT 2 внутри LATERAL даёт раннюю остановку после двух строк, тогда как
--     оконный DENSE_RANK обычно сортирует все товары категории и только потом
--     фильтрует. На больших категориях это заметная разница.
--   • CROSS означает, что категории без активных товаров исчезнут. Для
--     полноты отчёта с пустыми категориями использовали бы LEFT JOIN LATERAL.
--   • Индекс products(category_id) уже помогает; идеальный вариант —
--     (category_id, is_active, price DESC, product_id ASC), он позволит
--     прочитать две строки без сортировки.
--   • Паттерн Top-N per group через LATERAL особенно хорош, когда N мало и
--     нужен только часть столбцов.
-- =============================================================================

SELECT
    c.category_id,
    c.name AS category_name,
    p.product_id,
    p.name AS product_name,
    p.price
FROM categories c
CROSS JOIN LATERAL (
    SELECT
        product.product_id,
        product.name,
        product.price
    FROM products product
    WHERE product.category_id = c.category_id
      AND product.is_active = true
    ORDER BY product.price DESC, product.product_id ASC
    LIMIT 2
) p
ORDER BY c.category_id ASC, p.price DESC, p.product_id ASC;
