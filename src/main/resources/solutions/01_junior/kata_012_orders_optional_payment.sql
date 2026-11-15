-- =============================================================================
-- KATA 012 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Заказ и клиент соединяются INNER JOIN: связь обязательна по схеме.
--   • Платёж — необязательная сущность, поэтому LEFT JOIN.
--   • Условие p.status = 'captured' находится в ON, а не в WHERE. Если
--     перенести его в WHERE, LEFT JOIN фактически превратится в INNER JOIN
--     и отменённый заказ без успешного платежа потеряется.
--   • В данных один captured-платёж на заказ, поэтому дублирования нет.
--     В общем случае следовало бы агрегировать платежи или выбирать один
--     через LATERAL/окно.
--   • Полуинтервал по created_at и индексы orders/created_at, payments/order_id.
-- =============================================================================

SELECT
    o.order_id,
    o.created_at::date AS order_date,
    u.full_name,
    o.status AS order_status,
    p.method AS payment_method,
    p.amount AS payment_amount
FROM orders o
JOIN users u ON u.user_id = o.user_id
LEFT JOIN payments p
       ON p.order_id = o.order_id
      AND p.status = 'captured'
WHERE o.created_at >= TIMESTAMPTZ '2024-06-01 00:00:00+03'
  AND o.created_at <  TIMESTAMPTZ '2024-07-01 00:00:00+03'
ORDER BY o.order_id ASC;
