-- =============================================================================
-- KATA 068 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Anchor-часть рекурсии — корневые категории. Рекурсивная часть добавляет
--     дочерние категории и накапливает путь.
--   • path_ids защищает от случайного цикла в дереве и делает обход конечным
--     даже при повреждённых данных.
--   • Лист определяется через NOT EXISTS дочерних узлов. Это не зависит от
--     того, есть ли у категории товары.
--   • root_id сохраняется в каждой ветке, поэтому имя корня не нужно вычислять
--     повторно по строковому пути.
--   • Индекс categories(parent_id) ускоряет поиск детей на каждом уровне.
-- =============================================================================

WITH RECURSIVE tree AS (
    SELECT
        c.category_id,
        c.name,
        c.parent_id,
        c.category_id AS root_id,
        ARRAY[c.category_id] AS path_ids,
        1 AS depth,
        c.name::text AS path
    FROM categories c
    WHERE c.parent_id IS NULL

    UNION ALL

    SELECT
        c.category_id,
        c.name,
        c.parent_id,
        t.root_id,
        t.path_ids || c.category_id,
        t.depth + 1,
        t.path || ' -> ' || c.name
    FROM tree t
    JOIN categories c ON c.parent_id = t.category_id
    WHERE NOT c.category_id = ANY(t.path_ids)
)
SELECT
    t.category_id AS leaf_category_id,
    t.name AS leaf_name,
    root.name AS root_name,
    t.depth,
    t.path
FROM tree t
JOIN categories root ON root.category_id = t.root_id
WHERE NOT EXISTS (
    SELECT 1
    FROM categories child
    WHERE child.parent_id = t.category_id
)
ORDER BY t.category_id ASC;
