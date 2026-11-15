-- =============================================================================
-- KATA 010 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • SELF JOIN: employees используется дважды под разными псевдонимами.
--     e — сотрудник, m — его руководитель.
--   • LEFT JOIN обязателен, иначе топ-менеджеры с manager_id IS NULL
--     выпадут из отчёта. У них manager_name будет NULL — это корректно.
--   • Индекс employees(manager_id) помогает найти подчинённых, а поиск
--     руководителя идёт по первичному ключу employees(employee_id).
--   • employee_name/manager_name заданы явно, чтобы в результате не было
--     двух одинаковых колонок full_name.
-- =============================================================================

SELECT
    e.employee_id,
    e.full_name AS employee_name,
    e.manager_id,
    m.full_name AS manager_name,
    e.salary
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id
ORDER BY e.employee_id ASC;
