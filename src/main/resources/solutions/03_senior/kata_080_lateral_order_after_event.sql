-- =============================================================================
-- KATA 080 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • LEFT JOIN LATERAL — коррелированный Top-1: для каждого логина ищется
--     первый заказ строго после события.
--   • LEFT сохраняет событие, если заказа после него нет. Именно поэтому у
--     нового login_success пользователя 25 поля заказа NULL.
--   • ORDER BY created_at, order_id + LIMIT 1 делает выбор детерминированным
--     даже при двух заказах в одну секунду.
--   • Составной индекс orders(user_id, created_at, order_id) позволяет
--     выполнить поиск и сортировку по индексу без чтения всей истории.
--     Без него LATERAL на большом объёме будет делать дорогой сортирующий
--     проход для каждой строки audit_logs.
--   • В продакшене такие события читают из инкрементального потока/CDC;
--     в тренировке аудит — удобный источник фактов.
-- =============================================================================

SELECT
    a.log_id AS audit_log_id,
    a.actor_user_id AS user_id,
    u.full_name,
    a.action AS audit_action,
    a.occurred_at AS event_at,
    o.order_id AS next_order_id,
    o.created_at AS order_created_at,
    round(
        extract(epoch FROM (o.created_at - a.occurred_at)) / 3600.0,
        2
    ) AS hours_until_order
FROM audit_logs a
JOIN users u ON u.user_id = a.actor_user_id
LEFT JOIN LATERAL (
    SELECT
        ord.order_id,
        ord.created_at
    FROM orders ord
    WHERE ord.user_id = a.actor_user_id
      AND ord.created_at > a.occurred_at
    ORDER BY ord.created_at, ord.order_id
    LIMIT 1
) o ON true
WHERE a.action = 'login_success'
  AND a.success = true
  AND a.actor_user_id IS NOT NULL
ORDER BY a.log_id ASC;
