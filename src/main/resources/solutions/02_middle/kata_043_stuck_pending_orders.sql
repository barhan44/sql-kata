-- =============================================================================
-- KATA 043 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • as_of фиксирует контрольный момент, поэтому отчёт воспроизводим и
--     не зависит от реального now(). В продакшене здесь был бы параметр.
--   • Условие status = 'pending' сужает заказы до проблемных, а разность
--     с контрольным моментом > INTERVAL '24 hours' отсекает недавние.
--   • CROSS JOIN LATERAL выбирает один самый поздний captured-платёж на заказ.
--     Это защищает от дублирования заказа, если успешных попыток несколько,
--     и одновременно даёт поля платежа для отчёта.
--   • Индексы orders(status, created_at) и payments(order_id) помогают
--     фильтрации; partial index по captured-платежам мог бы ещё ускорить
--     выборку в продакшене.
--   • EXTRACT(EPOCH FROM interval) переводит интервал в секунды; деление
--     на 3600.0 и ROUND(..., 2) дают часы.
-- =============================================================================

WITH as_of AS (
    SELECT TIMESTAMPTZ '2024-07-01 00:00:00+03' AS at
)
SELECT
    o.order_id,
    o.user_id,
    u.full_name,
    o.created_at,
    round(
        extract(epoch FROM (a.at - o.created_at)) / 3600.0,
        2
    ) AS hours_pending,
    p.payment_id,
    p.amount,
    p.paid_at
FROM orders o
JOIN users u ON u.user_id = o.user_id
CROSS JOIN as_of a
CROSS JOIN LATERAL (
    SELECT p.payment_id, p.amount, p.paid_at
    FROM payments p
    WHERE p.order_id = o.order_id
      AND p.status = 'captured'
    ORDER BY p.paid_at DESC, p.payment_id DESC
    LIMIT 1
) p
WHERE o.status = 'pending'
  AND a.at - o.created_at > INTERVAL '24 hours'
ORDER BY o.order_id ASC;
