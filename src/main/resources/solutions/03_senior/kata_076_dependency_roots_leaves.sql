-- =============================================================================
-- KATA 076 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • dependency_paths запускает путь от каждой задачи. path защищает от
--     циклов, поэтому циклическая компонента не зациклит рекурсию.
--   • Корень — узел без исходящих рёбер (task_id отсутствует в
--     task_dependencies). Мы оставляем только пути, заканчивающиеся в таких
--     узлах; поэтому задачи 13–15, у которых нет корня, в результат не попадут.
--   • array_agg(DISTINCT ... ORDER BY ...) даёт отсортированный массив
--     уникальных корней. Вторичный SELECT собирает имена в том же порядке.
--   • is_leaf проверяет отсутствие входящих рёбер: никто не зависит от задачи.
--   • На больших графах можно использовать CYCLE для защиты и/или
--     материализовать транзитивное замыкание. Для небольшого DAG рекурсия
--     остаётся самым прозрачным решением.
-- =============================================================================

WITH RECURSIVE dependency_paths AS (
    SELECT
        n.task_id AS start_task_id,
        n.task_id AS current_task_id,
        ARRAY[n.task_id] AS path
    FROM task_nodes n

    UNION ALL

    SELECT
        p.start_task_id,
        td.depends_on_task_id,
        p.path || td.depends_on_task_id
    FROM dependency_paths p
    JOIN task_dependencies td ON td.task_id = p.current_task_id
    WHERE NOT td.depends_on_task_id = ANY(p.path)
),
root_ancestors AS (
    SELECT
        p.start_task_id,
        array_agg(DISTINCT p.current_task_id ORDER BY p.current_task_id)
            AS root_task_ids
    FROM dependency_paths p
    WHERE NOT EXISTS (
        SELECT 1
        FROM task_dependencies td
        WHERE td.task_id = p.current_task_id
    )
    GROUP BY p.start_task_id
)
SELECT
    t.task_id,
    t.task_name,
    r.root_task_ids,
    ARRAY(
        SELECT n.task_name
        FROM task_nodes n
        WHERE n.task_id = ANY(r.root_task_ids)
        ORDER BY n.task_id
    ) AS root_task_names,
    NOT EXISTS (
        SELECT 1
        FROM task_dependencies td
        WHERE td.depends_on_task_id = t.task_id
    ) AS is_leaf
FROM root_ancestors r
JOIN task_nodes t ON t.task_id = r.start_task_id
ORDER BY t.task_id ASC;
