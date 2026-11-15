-- =============================================================================
-- KATA 103 · Эталонное решение
-- =============================================================================
-- EXPLAIN-анализ:
--   План содержит два независимых HashAggregate: один по orders, второй по
--   support_tickets, затем Hash Left Join с users. Каждая 1-to-Many ветка
--   сворачивается до одной строки на user_id ДО соединения, поэтому
--   количество строк не перемножается, а Index Scan users по status быстро
--   выделяет активных клиентов.
--
-- Почему так:
--   • Сначала агрегируем каждую 1-to-Many ветку отдельно. Число строк в
--     каждой ветке сокращается до числа пользователей, после чего join
--     users × order_stats × ticket_stats уже не размножает заказы тикетами.
--   • COALESCE нужен, потому что LEFT JOIN для клиента без заказов/тикетов
--     возвращает NULL.
--   • COUNT(*) FILTER (WHERE status='OPEN') считает открытые тикеты в том же
--     проходе, что и общий ticket_count.
--   • Декартов взрыв можно увидеть на примере: 3 заказа × 4 тикета = 12 строк.
--     SUM(total_amount) в таком join считает каждый заказ четыре раза.
--   • На больших данных order_stats/ticket_stats можно материализовать, но
--     сначала нужно устранить неверную семантику чистым pre-aggregation.
-- =============================================================================

WITH order_stats AS (
    SELECT
        o.user_id,
        count(*) AS orders_count,
        COALESCE(sum(o.total_amount), 0::numeric) AS orders_total
    FROM orders o
    GROUP BY o.user_id
),
ticket_stats AS (
    SELECT
        st.user_id,
        count(*) AS tickets_count,
        count(*) FILTER (WHERE st.status = 'OPEN') AS open_tickets
    FROM support_tickets st
    GROUP BY st.user_id
)
SELECT
    u.user_id,
    u.full_name,
    COALESCE(os.orders_count, 0::bigint) AS orders_count,
    COALESCE(os.orders_total, 0::numeric) AS orders_total,
    COALESCE(ts.tickets_count, 0::bigint) AS tickets_count,
    COALESCE(ts.open_tickets, 0::bigint) AS open_tickets
FROM users u
LEFT JOIN order_stats os ON os.user_id = u.user_id
LEFT JOIN ticket_stats ts ON ts.user_id = u.user_id
WHERE u.status = 'active'
ORDER BY u.user_id ASC;
