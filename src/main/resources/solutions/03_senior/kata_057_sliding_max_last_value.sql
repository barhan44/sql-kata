-- =============================================================================
-- KATA 057 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • MAX с фреймом 2 PRECEDING..CURRENT включает текущий и два предыдущих
--     заказа. Для первого заказа окно состоит только из него.
--   • LAST_VALUE по умолчанию использует RANGE CURRENT ROW, то есть
--     возвращает текущую строку. Явный UNBOUNDED FOLLOWING расширяет кадр до
--     конца раздела и даёт последний заказ клиента.
--   • Именованные окна убирают дублирование PARTITION BY/ORDER BY. Фрейм
--     LAST_VALUE отличается, поэтому это отдельное окно.
--   • total_amount сравнивается с rolling_max_3 после вычисления окон во
--     внешнем SELECT: ссылаться на псевдоним окна в том же уровне нельзя.
--   • order_id в ORDER BY — tie-breaker для заказов с одинаковым временем.
-- =============================================================================

WITH windowed AS (
    SELECT
        user_id,
        order_id,
        created_at,
        total_amount,
        max(total_amount) OVER recent_three AS rolling_max_3,
        last_value(total_amount) OVER full_partition AS last_order_amount
    FROM orders
    WINDOW
        recent_three AS (
            PARTITION BY user_id
            ORDER BY created_at, order_id
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        full_partition AS (
            PARTITION BY user_id
            ORDER BY created_at, order_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )
)
SELECT
    user_id,
    order_id,
    created_at,
    total_amount,
    rolling_max_3,
    total_amount = rolling_max_3 AS is_rolling_max,
    last_order_amount,
    last_order_amount - total_amount AS difference_to_last
FROM windowed
ORDER BY user_id ASC, created_at ASC, order_id ASC;
