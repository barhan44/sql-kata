-- =============================================================================
-- KATA 072 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Для каждого существующего ребра запускается путь по depends_on_task_id.
--   • path накапливает посещённые узлы. Если следующий узел уже есть в path,
--     строка помечается is_cycle и рекурсия из неё не продолжается.
--   • Фильтр path[cardinality(path)] = start_task_id оставляет только циклы,
--     которые вернулись в стартовую вершину. Для цикла 13→14→15→13 это даёт
--     три ротации, по одной на каждую стартовую точку.
--   • cycle_length = cardinality(path) - 1, потому что последний элемент —
--     повтор стартовой вершины.
--   • В PostgreSQL 14+ вместо ручного массива можно использовать
--     CYCLE current_task_id SET is_cycle USING cycle_path. Встроенный вариант
--     лаконичнее, но ручной path прозрачно показывает, как именно
--     обнаруживается повтор.
--   • Для поиска любого одного цикла достаточно ограничить anchor одним
--     task_id; здесь намеренно показаны все циклы для наглядности.
-- =============================================================================

WITH RECURSIVE walk AS (
    SELECT
        td.task_id AS start_task_id,
        td.depends_on_task_id AS current_task_id,
        ARRAY[td.task_id, td.depends_on_task_id] AS path,
        false AS is_cycle
    FROM task_dependencies td

    UNION ALL

    SELECT
        w.start_task_id,
        td.depends_on_task_id,
        w.path || td.depends_on_task_id,
        td.depends_on_task_id = ANY(w.path) AS is_cycle
    FROM walk w
    JOIN task_dependencies td ON td.task_id = w.current_task_id
    WHERE NOT w.is_cycle
)
SELECT
    start_task_id AS starting_task_id,
    path AS cycle_path,
    cardinality(path) - 1 AS cycle_length
FROM walk
WHERE is_cycle
  AND path[cardinality(path)] = start_task_id
ORDER BY starting_task_id ASC;
