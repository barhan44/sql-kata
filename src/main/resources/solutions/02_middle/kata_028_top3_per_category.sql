-- =============================================================================
-- KATA 028 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Паттерн Top-N per group: сначала оконная функция ранжирует товары
--     внутри категории, затем внешний запрос фильтрует по рангу. Фильтровать
--     оконную функцию в WHERE того же SELECT нельзя.
--   • DENSE_RANK не оставляет «дыр» при равных ценах: товары с одинаковой
--     ценой получат одинаковый ранг и могут вместе попасть в Top-3.
--     Если нужен ровно N строк, используют ROW_NUMBER с tie-breaker.
--   • INNER JOIN с categories исключает товары без категории. LEFT JOIN
--     оставил бы category_name NULL, но по условию такие товары не нужны.
--   • Индекс products(category_id) помогает разбиению на разделы,
--     products(is_active, price) — фильтру активных товаров.
-- =============================================================================

WITH ranked AS (
    SELECT
        c.category_id,
        c.name AS category_name,
        p.product_id,
        p.name AS product_name,
        p.price,
        dense_rank() OVER (
            PARTITION BY p.category_id
            ORDER BY p.price DESC
        ) AS price_rank
    FROM products p
    JOIN categories c ON c.category_id = p.category_id
    WHERE p.is_active = true
)
SELECT
    category_id,
    category_name,
    product_id,
    product_name,
    price,
    price_rank
FROM ranked
WHERE price_rank <= 3
ORDER BY category_id ASC, price_rank ASC, product_id ASC;
