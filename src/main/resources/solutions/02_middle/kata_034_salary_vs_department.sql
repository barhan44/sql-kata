-- =============================================================================
-- KATA 034 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Оконные AVG и MAX возвращают агрегат отдела в каждой строке сотрудника,
--     не сворачивая строки, как GROUP BY.
--   • FIRST_VALUE по умолчанию использует кадр до текущей строки. С ним
--     в каждой строке был бы её собственный сотрудник. Явный
--     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
--     расширяет кадр на весь раздел и даёт настоящего топ-сотрудника.
--   • AVG имеет тип numeric; ROUND(...,2) задаёт точность вывода. Процент
--     считается от уже округлённой средней, как указано в контракте каты.
--   • PARTITION BY department_id создаёт отдельное окно для NULL-отдела.
--   • LEFT JOIN сохраняет сотрудника без отдела. Сортировка NULLS LAST
--     отправляет его в конец отчёта.
-- =============================================================================

WITH metrics AS (
    SELECT
        e.department_id,
        d.name AS department_name,
        e.employee_id,
        e.full_name AS employee_name,
        e.salary,
        round(avg(e.salary) OVER (PARTITION BY e.department_id), 2)
            AS department_avg_salary,
        max(e.salary) OVER (PARTITION BY e.department_id)
            AS department_max_salary,
        first_value(e.full_name) OVER (
            PARTITION BY e.department_id
            ORDER BY e.salary DESC, e.employee_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS top_earner
    FROM employees e
    LEFT JOIN departments d ON d.department_id = e.department_id
)
SELECT
    department_id,
    department_name,
    employee_id,
    employee_name,
    salary,
    department_avg_salary,
    department_max_salary,
    top_earner,
    round(
        (salary - department_avg_salary)
        / NULLIF(department_avg_salary, 0) * 100,
        2
    ) AS salary_vs_avg_pct
FROM metrics
ORDER BY department_id ASC NULLS LAST,
         salary DESC,
         employee_id ASC;
