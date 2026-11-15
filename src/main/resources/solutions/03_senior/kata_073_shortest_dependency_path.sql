-- =============================================================================
-- KATA 073 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • START — рёбра из вершины 12. Каждая строка хранит пройденный путь,
--     число hops и защиту от повторного посещения.
--   • SEARCH BREADTH FIRST BY current_task_id SET bfs_order — встроенный
--     синтаксис PostgreSQL для BFS-порядка. Он не заменяет ORDER BY итогового
--     результата, но даёт планировщику и читателю явную семантику обхода.
--   • Рекурсивная ветка не продолжает путь после target=1, поэтому в routes
--     остаются только маршруты, завершившиеся в целевой вершине (а также
--     незавершённые, которые отфильтрует WHERE).
--   • Сортировка hops, path_task_ids и LIMIT 1 выбирает кратчайший путь;
--     при равенстве лексикографически меньшее представление делает результат
--     детерминированным.
--   • Массив path_task_names собирается через array_position, сохраняя порядок
--     ID в path_task_ids.
-- =============================================================================

WITH RECURSIVE routes AS (
    SELECT
        12::integer AS source_task_id,
        td.depends_on_task_id AS current_task_id,
        ARRAY[12, td.depends_on_task_id]::integer[] AS path_task_ids,
        1 AS hops
    FROM task_dependencies td
    WHERE td.task_id = 12

    UNION ALL

    SELECT
        r.source_task_id,
        td.depends_on_task_id,
        r.path_task_ids || td.depends_on_task_id,
        r.hops + 1
    FROM routes r
    JOIN task_dependencies td ON td.task_id = r.current_task_id
    WHERE r.current_task_id <> 1
      AND NOT td.depends_on_task_id = ANY(r.path_task_ids)
)
SEARCH BREADTH FIRST BY current_task_id SET bfs_order
SELECT
    r.source_task_id,
    1::integer AS target_task_id,
    r.hops,
    r.path_task_ids,
    ARRAY(
        SELECT node.task_name
        FROM task_nodes node
        WHERE node.task_id = ANY(r.path_task_ids)
        ORDER BY array_position(r.path_task_ids, node.task_id)
    ) AS path_task_names
FROM routes r
WHERE r.current_task_id = 1
ORDER BY r.hops ASC, r.path_task_ids ASC
LIMIT 1;
