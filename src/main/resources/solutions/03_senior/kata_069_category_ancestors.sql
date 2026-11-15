-- =============================================================================
-- KATA 069 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Anchor — категории выбранных товаров на глубине 1.
--   • Рекурсивный шаг поднимается к parent и ПРЕДпосылает имя родителя к пути.
--     В результате после достижения корня строка содержит путь от корня к
--     листу в правильном порядке.
--   • path_ids не позволяет зациклиться при некорректном parent_id.
--   • Финальный WHERE parent_id IS NULL оставляет только завершённые цепочки:
--     промежуточные итерации не попадают в результат.
--   • levels считает количество категорий, включая непосредственную категорию.
-- =============================================================================

WITH RECURSIVE ancestry AS (
    SELECT
        p.product_id,
        p.name AS product_name,
        c.category_id,
        c.parent_id,
        ARRAY[c.category_id] AS path_ids,
        1 AS levels,
        c.name::text AS category_path
    FROM products p
    JOIN categories c ON c.category_id = p.category_id
    WHERE p.product_id IN (1, 5, 13, 20, 22)

    UNION ALL

    SELECT
        a.product_id,
        a.product_name,
        parent.category_id,
        parent.parent_id,
        a.path_ids || parent.category_id,
        a.levels + 1,
        parent.name || ' -> ' || a.category_path
    FROM ancestry a
    JOIN categories parent ON parent.category_id = a.parent_id
    WHERE NOT parent.category_id = ANY(a.path_ids)
)
SELECT
    product_id,
    product_name,
    category_path,
    levels
FROM ancestry
WHERE parent_id IS NULL
ORDER BY product_id ASC;
