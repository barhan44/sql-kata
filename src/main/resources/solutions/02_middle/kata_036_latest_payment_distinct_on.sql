-- =============================================================================
-- KATA 036 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • DISTINCT ON (u.user_id) — идиоматичный PostgreSQL-способ оставить первую
--     строку каждого раздела. Первая строка определяется ORDER BY, поэтому
--     user_id обязан идти первым, а затем идёт сортировка по paid_at DESC.
--   • NULLS LAST отодвигает пользователей без успешных платежей в конец
--     раздела, поэтому реальный платёж всегда выбирается раньше NULL-строки.
--   • LEFT JOIN сохраняет всех 25 клиентов. Failed/authorized отфильтрованы
--     в ON, чтобы не превратить LEFT JOIN в INNER JOIN.
--   • Сравнение с ROW_NUMBER:
--       SELECT ... FROM (
--         SELECT ..., row_number() OVER (
--           PARTITION BY u.user_id
--           ORDER BY p.paid_at DESC NULLS LAST, p.payment_id DESC
--         ) AS rn
--       ) x WHERE rn = 1;
--     ROW_NUMBER более переносим и позволяет фильтровать/сортировать
--     произвольно. DISTINCT ON короче и на PostgreSQL часто эффективнее,
--     но требует строго определённого порядка ORDER BY.
--   • Индексы orders(user_id) и payments(order_id) ускоряют соединение,
--     payments(paid_at) — поиск последнего платежа на больших объёмах.
-- =============================================================================

SELECT DISTINCT ON (u.user_id)
    u.user_id,
    u.full_name,
    p.payment_id,
    p.order_id,
    p.status,
    p.amount,
    p.paid_at
FROM users u
LEFT JOIN orders o ON o.user_id = u.user_id
LEFT JOIN payments p
       ON p.order_id = o.order_id
      AND p.status IN ('captured', 'refunded')
ORDER BY u.user_id ASC,
         p.paid_at DESC NULLS LAST,
         p.payment_id DESC;
