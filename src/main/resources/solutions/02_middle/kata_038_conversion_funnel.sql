-- =============================================================================
-- KATA 038 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Каждый шаг воронки считается независимо в своём CTE. Это проще
--     проверять и нельзя случайно потерять пользователей из-за неудачного JOIN.
--   • COUNT(DISTINCT user_id) не даёт посчитать пользователя дважды, если
--     у него несколько заказов или captured-платежей.
--   • stages использует UNION ALL: шаги концептуально разные, дедупликация
--     не нужна. Порядок шагов фиксируется stage_order.
--   • first_value(users_count) OVER (ORDER BY stage_order) даёт знаменатель
--     зарегистрированных; lag — предыдущий шаг. Для первого шага lag = NULL,
--     поэтому step_conversion_pct = NULL без специального CASE.
--   • 100.0 включает numeric-арифметику, ROUND(...,2) задаёт точность.
--   • Индексы orders(user_id), payments(order_id) ускоряют проверки на больших
--     объёмах.
-- =============================================================================

WITH orders_per_user AS (
    SELECT user_id, count(*) AS orders_count
    FROM orders
    GROUP BY user_id
),
paid_users AS (
    SELECT DISTINCT o.user_id
    FROM orders o
    JOIN payments p ON p.order_id = o.order_id
    WHERE p.status = 'captured'
),
stages AS (
    SELECT 1 AS stage_order, 'registered' AS stage, count(*) AS users_count
    FROM users
    UNION ALL
    SELECT 2, 'first_order', count(*)
    FROM orders_per_user
    UNION ALL
    SELECT 3, 'paid', count(*)
    FROM paid_users
    UNION ALL
    SELECT 4, 'repeat_order', count(*)
    FROM orders_per_user
    WHERE orders_count >= 2
),
metrics AS (
    SELECT
        stage_order,
        stage,
        users_count,
        round(
            100.0 * users_count
            / NULLIF(first_value(users_count) OVER (ORDER BY stage_order), 0),
            2
        ) AS pct_of_registered,
        round(
            100.0 * users_count
            / NULLIF(lag(users_count) OVER (ORDER BY stage_order), 0),
            2
        ) AS step_conversion_pct
    FROM stages
)
SELECT
    stage_order,
    stage,
    users_count,
    pct_of_registered,
    step_conversion_pct
FROM metrics
ORDER BY stage_order ASC;
