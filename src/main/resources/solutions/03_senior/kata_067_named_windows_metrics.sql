-- =============================================================================
-- KATA 067 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Именованные окна один раз описывают PARTITION BY/ORDER BY и кадры,
--     после чего 4 метрики ссылаются на них по имени.
--   • ordered — окно порядка; running — явный накопительный кадр
--     UNBOUNDED PRECEDING..CURRENT ROW; moving3 — три последние строки;
--     by_user — общий раздел клиента для доли.
--   • Для накопительной суммы и доли используются numeric-вычисления над
--     денежными значениями без потери точности.
--   • order_id — tie-breaker для заказов с одинаковым created_at.
--   • WINDOW-секция особенно полезна, когда метрик много: риск рассинхронизации
--     определений и дублирования кода резко снижается.
-- =============================================================================

SELECT
    user_id,
    order_id,
    created_at,
    total_amount,
    row_number() OVER ordered AS order_number,
    sum(total_amount) OVER running AS running_total,
    round(avg(total_amount) OVER moving3, 2) AS moving_avg_3,
    round(
        100.0 * total_amount / NULLIF(sum(total_amount) OVER by_user, 0),
        2
    ) AS user_share_pct
FROM orders
WINDOW
    ordered AS (
        PARTITION BY user_id
        ORDER BY created_at, order_id
    ),
    running AS (
        PARTITION BY user_id
        ORDER BY created_at, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ),
    moving3 AS (
        PARTITION BY user_id
        ORDER BY created_at, order_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ),
    by_user AS (
        PARTITION BY user_id
    )
ORDER BY user_id ASC, created_at ASC, order_id ASC;
