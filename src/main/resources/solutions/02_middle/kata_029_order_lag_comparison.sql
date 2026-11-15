-- =============================================================================
-- KATA 029 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Именованное окно w объединяет PARTITION BY и ORDER BY, поэтому
--     два LAG не дублируют определение.
--   • LAG(..., 1) — значение предыдущей строки. Для первой строки окна оно
--     NULL, и любые арифметические выражения с ним тоже дают NULL — это
--     корректное поведение для первого заказа.
--   • EXTRACT(EPOCH FROM interval) превращает интервал в секунды, деление
--     на 3600.0 даёт часы в numeric. ROUND(..., 2) фиксирует точность.
--   • order_id в ORDER BY — tie-breaker для заказов с одинаковым created_at.
--   • Индекс orders(user_id) и сортировка по времени позволяют PostgreSQL
--     эффективнее подготовить окно; на малом объёме планировщик может выбрать
--     обычную сортировку.
-- =============================================================================

WITH compared AS (
    SELECT
        user_id,
        order_id,
        created_at,
        total_amount,
        lag(order_id) OVER w AS previous_order_id,
        lag(total_amount) OVER w AS previous_amount,
        lag(created_at) OVER w AS previous_created_at
    FROM orders
    WINDOW w AS (
        PARTITION BY user_id
        ORDER BY created_at, order_id
    )
)
SELECT
    user_id,
    order_id,
    created_at,
    total_amount,
    previous_order_id,
    previous_amount,
    total_amount - previous_amount AS amount_delta,
    round(
        extract(epoch FROM (created_at - previous_created_at)) / 3600.0,
        2
    ) AS hours_since_previous
FROM compared
ORDER BY user_id ASC, created_at ASC, order_id ASC;
