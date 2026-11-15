-- =============================================================================
-- KATA 077 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Для валидации глубины нужен рекурсивный обход только от корней.
--     Узлы с отсутствующим parent_id в этот обход не попадут — их ищет
--     отдельная ветка через NOT EXISTS.
--   • parent_id в staging намеренно без FK: именно такие ссылки и должны
--     отлавливаться до публикации данных.
--   • path_ids защищает обход от случайных циклов в staging.
--   • two CTE (tree, too_deep) и отдельный orphan-запрос объединяются через
--     UNION ALL. depth у сироты — NULL, потому что вычислить уровень без
--     родителя невозможно.
--   • На продакшене staging обычно загружают в отдельную схему и валидируют
--     constraint-ами/триггерами до MERGE; этот запрос — последний рубеж.
-- =============================================================================

WITH RECURSIVE tree AS (
    SELECT
        n.node_id,
        n.name,
        n.parent_id,
        ARRAY[n.node_id] AS path_ids,
        1 AS depth
    FROM category_tree_staging n
    WHERE n.parent_id IS NULL

    UNION ALL

    SELECT
        child.node_id,
        child.name,
        child.parent_id,
        t.path_ids || child.node_id,
        t.depth + 1
    FROM tree t
    JOIN category_tree_staging child ON child.parent_id = t.node_id
    WHERE NOT child.node_id = ANY(t.path_ids)
),
too_deep AS (
    SELECT
        node_id,
        name,
        parent_id,
        depth,
        'too_deep'::text AS issue
    FROM tree
    WHERE depth > 3
),
orphans AS (
    SELECT
        n.node_id,
        n.name,
        n.parent_id,
        NULL::integer AS depth,
        'orphan'::text AS issue
    FROM category_tree_staging n
    WHERE n.parent_id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM category_tree_staging parent
          WHERE parent.node_id = n.parent_id
      )
)
SELECT node_id, name, parent_id, depth, issue
FROM too_deep
UNION ALL
SELECT node_id, name, parent_id, depth, issue
FROM orphans
ORDER BY node_id ASC;
