-- =============================================================================
-- KATA 037 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • COUNT(*) FILTER (WHERE ...) — стандартный PostgreSQL-способ условной
--     агрегации. Он читается лучше CASE WHEN ... THEN 1 ELSE 0 END и
--     не создаёт лишнюю ветку ELSE.
--   • Один GROUP BY и один проход по orders дают все статусы одновременно.
--   • SUM(total_amount) FILTER (WHERE status='delivered') считает только
--     доставленную выручку. COALESCE(...,0::numeric) гарантирует numeric 0,
--     если в месяце нет доставленных заказов.
--   • date_trunc('month', timestamptz) возвращает timestamptz; ::date
--     фиксирует тип колонки month и убирает время.
--   • Индекс orders(status, created_at) полезен для фильтрованных отчётов,
--     а здесь выполняется последовательное чтение и hash aggregate.
-- =============================================================================

SELECT
    date_trunc('month', created_at)::date AS month,
    count(*) AS total_orders,
    count(*) FILTER (WHERE status = 'pending') AS pending_orders,
    count(*) FILTER (WHERE status = 'paid') AS paid_orders,
    count(*) FILTER (WHERE status = 'shipped') AS shipped_orders,
    count(*) FILTER (WHERE status = 'delivered') AS delivered_orders,
    count(*) FILTER (WHERE status = 'cancelled') AS cancelled_orders,
    count(*) FILTER (WHERE status = 'returned') AS returned_orders,
    COALESCE(
        sum(total_amount) FILTER (WHERE status = 'delivered'),
        0::numeric
    ) AS delivered_revenue
FROM orders
GROUP BY date_trunc('month', created_at)::date
ORDER BY month ASC;
