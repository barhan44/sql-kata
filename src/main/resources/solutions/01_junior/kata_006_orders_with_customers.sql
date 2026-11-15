-- =============================================================================
-- KATA 006 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • INNER JOIN корректен: orders.user_id NOT NULL и ссылается на users,
--     поэтому «бесхозных» заказов быть не может.
--   • Границы квартала заданы как полуинтервал [1 января; 1 апреля).
--     Это стандартный и безопасный способ для timestamp-диапазонов: не нужно
--     помнить про 23:59:59.999999 и часовой пояс.
--   • Фильтр по created_at может использовать orders_created_at_idx.
--   • Явный ::date фиксирует тип order_date = date.
--   • Сортировка по псевдониму order_date плюс order_id даёт стабильный
--     результат для заказов, созданных в одну дату.
-- =============================================================================

SELECT
    o.order_id,
    o.created_at::date AS order_date,
    o.user_id,
    u.full_name,
    o.status,
    o.total_amount
FROM orders o
JOIN users u ON u.user_id = o.user_id
WHERE o.created_at >= TIMESTAMPTZ '2024-01-01 00:00:00+03'
  AND o.created_at <  TIMESTAMPTZ '2024-04-01 00:00:00+03'
  AND o.status IN ('paid', 'shipped', 'delivered')
ORDER BY order_date ASC, o.order_id ASC;
