-- =============================================================================
-- KATA 050 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • `&&` проверяет пересечение двух массивов и может использовать
--     GIN-индекс products_tags_gin_idx. Это быстрый способ найти товары
--     по любому из целевых тегов.
--   • `'anc' = ANY(p.tags)` — поиск конкретного элемента; bool_or сворачивает
--     результат по группе в один boolean.
--   • LATERAL unnest разворачивает нативные массивы в строки. DISTINCT внутри
--     array_agg нужен, потому что после unnest один товар встречается столько
--     раз, сколько у него тегов.
--   • array_agg(DISTINCT ... ORDER BY ...) создаёт детерминированные массивы;
--     без ORDER BY порядок элементов не гарантирован.
--   • INNER JOIN с categories исключает товары без категории.
--   • COUNT(DISTINCT product_id) считает товары, а не строки после unnest.
-- =============================================================================

WITH target_tags AS (
    SELECT ARRAY['apple', '5g', 'anc']::text[] AS tags
)
SELECT
    c.name AS category_name,
    count(DISTINCT p.product_id) AS product_count,
    array_agg(DISTINCT p.name ORDER BY p.name ASC) AS product_names,
    array_agg(DISTINCT tag ORDER BY tag ASC) AS tags,
    bool_or('anc' = ANY(p.tags)) AS has_anc
FROM products p
JOIN categories c ON c.category_id = p.category_id
CROSS JOIN target_tags t
CROSS JOIN LATERAL unnest(p.tags) AS u(tag)
WHERE p.is_active = true
  AND p.tags && t.tags
GROUP BY c.category_id, c.name
ORDER BY category_name ASC;
