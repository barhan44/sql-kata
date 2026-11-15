-- =============================================================================
-- KATA 027 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • ROW_NUMBER всегда выдаёт уникальные номера, поэтому для стабильности
--     нужен tie-breaker employee_id.
--   • RANK и DENSE_RANK сознательно сортируются только по salary. Тогда
--     равные зарплаты получают одинаковый ранг.
--   • Разница: RANK после двух одинаковых зарплат «перепрыгивает» номера,
--     DENSE_RANK — нет. Например, в Product: 400, 240, 240, 180 даёт
--     row_number 1..4, RANK 1,2,2,4, DENSE_RANK 1,2,2,3.
--   • PARTITION BY department_id включает и NULL-отдел: все такие сотрудники
--     попадают в одно окно.
--   • LEFT JOIN нужен, чтобы не потерять сотрудника без отдела.
-- =============================================================================

SELECT
    e.department_id,
    d.name AS department_name,
    e.employee_id,
    e.full_name AS employee_name,
    e.salary,
    row_number() OVER (
        PARTITION BY e.department_id
        ORDER BY e.salary DESC, e.employee_id
    ) AS row_number,
    rank() OVER (
        PARTITION BY e.department_id
        ORDER BY e.salary DESC
    ) AS rank_position,
    dense_rank() OVER (
        PARTITION BY e.department_id
        ORDER BY e.salary DESC
    ) AS dense_rank_position
FROM employees e
LEFT JOIN departments d ON d.department_id = e.department_id
ORDER BY e.department_id ASC NULLS LAST,
         e.salary DESC,
         e.employee_id ASC;
