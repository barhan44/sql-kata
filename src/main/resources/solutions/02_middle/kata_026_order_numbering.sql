-- =============================================================================
-- KATA 026 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • ROW_NUMBER нумерует строки внутри окна клиента, не склеивая их и не
--     теряя остальные заказы. Это оконная функция, а не GROUP BY.
--   • Порядок created_at + order_id полностью детерминирован. Без order_id
--     два заказа с одинаковым временем могли бы получить номера по-разному
--     от запуска к запуску.
--   • COUNT(*) OVER (...) даёт общее число заказов в каждой строке, поэтому
--     последний заказ можно отметить без отдельного подзапроса.
--   • Флаги вычисляются во внешнем SELECT: ссылаться на оконные псевдонимы
--     в том же уровне SELECT нельзя.
--   • Индекс orders(user_id) помогает сортировке внутри разделов.
-- =============================================================================

WITH numbered AS (
    SELECT
        o.order_id,
        o.user_id,
        u.full_name,
        o.created_at,
        o.total_amount,
        row_number() OVER (
            PARTITION BY o.user_id
            ORDER BY o.created_at, o.order_id
        ) AS order_number,
        count(*) OVER (PARTITION BY o.user_id) AS orders_total
    FROM orders o
    JOIN users u ON u.user_id = o.user_id
)
SELECT
    order_id,
    user_id,
    full_name,
    created_at,
    total_amount,
    order_number,
    orders_total,
    order_number = 1 AS is_first_order,
    order_number = orders_total AS is_last_order
FROM numbered
ORDER BY user_id ASC, order_number ASC;
