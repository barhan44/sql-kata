-- =============================================================================
-- KATA 070 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • category_descendants строит транзитивное замыкание «предок → потомок»
--     для всех категорий, включая саму категорию (depth 0).
--   • direct_sales агрегирует доставленную выручку по непосредственной
--     категории товара.
--   • subtree_revenue — сумма direct_sales по всем descendant_id, а не только
--     по прямым детям. Поэтому работают уровни любой глубины.
--   • LEFT JOIN сохраняет категории без продаж; COALESCE даёт numeric 0.
--   • Ограничение depth < 10 — страховка от повреждённого дерева и циклов.
--   • На больших каталогах часто материализуют closure table или recursive
--     CTE с индексом categories(parent_id), чтобы не пересчитывать предков.
-- =============================================================================

WITH RECURSIVE category_descendants AS (
    SELECT
        c.category_id AS ancestor_id,
        c.category_id AS descendant_id,
        0 AS depth
    FROM categories c

    UNION ALL

    SELECT
        d.ancestor_id,
        child.category_id,
        d.depth + 1
    FROM category_descendants d
    JOIN categories child ON child.parent_id = d.descendant_id
    WHERE d.depth < 10
),
direct_sales AS (
    SELECT
        p.category_id,
        sum(oi.line_total) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.status = 'delivered'
    GROUP BY p.category_id
)
SELECT
    a.category_id,
    a.name AS category_name,
    COALESCE(own.revenue, 0::numeric) AS direct_revenue,
    COALESCE(sum(sub.revenue), 0::numeric) AS subtree_revenue
FROM categories a
JOIN category_descendants d ON d.ancestor_id = a.category_id
LEFT JOIN direct_sales own ON own.category_id = a.category_id
LEFT JOIN direct_sales sub ON sub.category_id = d.descendant_id
GROUP BY a.category_id, a.name, own.revenue
ORDER BY a.category_id ASC;
