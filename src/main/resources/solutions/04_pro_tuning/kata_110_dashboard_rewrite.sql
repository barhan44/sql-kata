-- =============================================================================
-- KATA 110 · Эталонное решение
-- =============================================================================
-- EXPLAIN (ANALYZE): Bitmap Index Scan on events_big_status_created_idx
--   -> Bitmap Heap Scan (330 rows) -> HashAggregate -> Hash Left Join
--   support_tickets aggregate -> Sort/Limit.
-- Seq Scan по events_big отсутствует.
--
-- Почему так:
--   • Полуоткрытый временной диапазон и status='PAID' оставлены SARGable;
--     индекс (status, created_at) читает только ~330 строк мая 2025.
--   • events_big агрегируется один раз до join; DISTINCT после join больше не
--     нужен, потому что каждая ветка уже сведена к одной строке на user_id.
--   • support_tickets агрегируется отдельно. Иначе join «заказы × тикеты»
--     размножил бы строки и исказил paid_revenue.
--   • Вместо коррелированного подзапроса на каждый user_id — один GROUP BY
--     по 200 тикетам и hash join.
--   • ROW_NUMBER даёт стабильный revenue_rank при равной выручке (tie-breaker
--     user_id). Мы сортируем 10 элементов, а не все строки.
--   • OFFSET 0 удалён. Для следующих страниц правильнее keyset pagination по
--     (paid_revenue, user_id), а не OFFSET, который линейно деградирует.
--   • На реальном масштабе monthly revenue обычно материализуют в отдельную
--     витрину; здесь индексный доступ и корректная pre-aggregation решают
--     задачу без изменения схемы.
-- =============================================================================

WITH money AS (
    SELECT
        e.user_id,
        count(*) AS paid_events,
        sum(e.amount) AS paid_revenue
    FROM events_big e
    WHERE e.status = 'PAID'
      AND e.created_at >= TIMESTAMPTZ '2025-05-01 00:00:00+03'
      AND e.created_at <  TIMESTAMPTZ '2025-06-01 00:00:00+03'
    GROUP BY e.user_id
),
tickets AS (
    SELECT
        st.user_id,
        count(*) AS ticket_count
    FROM support_tickets st
    GROUP BY st.user_id
),
dashboard AS (
    SELECT
        u.user_id,
        u.full_name,
        m.paid_events,
        m.paid_revenue,
        COALESCE(t.ticket_count, 0::bigint) AS ticket_count,
        row_number() OVER (
            ORDER BY m.paid_revenue DESC, u.user_id ASC
        ) AS revenue_rank
    FROM money m
    JOIN users u ON u.user_id = m.user_id
    LEFT JOIN tickets t ON t.user_id = u.user_id
)
SELECT
    user_id,
    full_name,
    paid_events,
    paid_revenue,
    ticket_count,
    revenue_rank
FROM dashboard
WHERE revenue_rank <= 10
ORDER BY revenue_rank ASC;
