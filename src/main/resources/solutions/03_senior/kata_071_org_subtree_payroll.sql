-- =============================================================================
-- KATA 071 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Anchor запускает отдельный путь от каждого сотрудника как возможного
--     руководителя. Рекурсивная часть добавляет всех прямых и косвенных
--     подчинённых по manager_id.
--   • Каждая строка branch — один потомок (включая самого менеджера с depth 0).
--     count(*) - 1 даёт число подчинённых без руководителя.
--   • SUM(salary) по всем потомкам включает зарплату руководителя — это
--     соответствует определению фонда оплаты всей ветки.
--   • HAVING count(*) > 1 оставляет только реальных руководителей.
--   • Индекс employees(manager_id) ускоряет рекурсивный шаг; на очень глубоких
--     деревьях может помочь материализованный closure table.
-- =============================================================================

WITH RECURSIVE branch AS (
    SELECT
        e.employee_id AS manager_id,
        e.employee_id AS descendant_id,
        0 AS depth
    FROM employees e

    UNION ALL

    SELECT
        b.manager_id,
        subordinate.employee_id,
        b.depth + 1
    FROM branch b
    JOIN employees subordinate ON subordinate.manager_id = b.descendant_id
)
SELECT
    m.employee_id AS manager_id,
    m.full_name AS manager_name,
    count(*) - 1 AS subordinates_count,
    round(sum(d.salary), 2)::numeric(12, 2) AS branch_payroll
FROM branch b
JOIN employees m ON m.employee_id = b.manager_id
JOIN employees d ON d.employee_id = b.descendant_id
GROUP BY m.employee_id, m.full_name
HAVING count(*) > 1
ORDER BY m.employee_id ASC;
