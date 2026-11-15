-- =============================================================================
-- KATA 078 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Рекурсивный CTE собирает sort_path — массив имён от корня до текущего
--     узла. Для сестринских узлов различается последний элемент, поэтому
--     сортировка массива даёт правильный DFS pre-order при name ASC.
--   • PostgreSQL сравнивает массивы лексикографически: родитель [Books]
--     идёт раньше потомка [Books, Fiction], а Fiction — раньше Nonfiction.
--   • id_path защищает от циклов в parent_id.
--   • traversal_order вычисляется ROW_NUMBER по sort_path уже после обхода.
--   • Индекс categories(parent_id) ускоряет переходы к дочерним узлам.
-- =============================================================================

WITH RECURSIVE tree AS (
    SELECT
        c.category_id,
        c.name,
        c.parent_id,
        ARRAY[c.category_id] AS id_path,
        1 AS depth,
        ARRAY[c.name]::text[] AS sort_path
    FROM categories c
    WHERE c.parent_id IS NULL

    UNION ALL

    SELECT
        c.category_id,
        c.name,
        c.parent_id,
        t.id_path || c.category_id,
        t.depth + 1,
        t.sort_path || c.name
    FROM tree t
    JOIN categories c ON c.parent_id = t.category_id
    WHERE NOT c.category_id = ANY(t.id_path)
)
SELECT
    row_number() OVER (ORDER BY sort_path) AS traversal_order,
    category_id,
    name,
    parent_id,
    depth,
    array_to_string(sort_path, ' -> ') AS path
FROM tree
ORDER BY sort_path ASC;
