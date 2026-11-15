-- =============================================================================
-- KATA 066 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • generate_series создаёт все 12 месяцев, поэтому месяцы без продаж
--     не исчезают из отчёта.
--   • status = 'delivered' находится в ON: LEFT JOIN сохраняет месяц, даже
--     если доставленных заказов в нём нет; COALESCE даёт 0.
--   • LAG смотрит на предыдущую строку календаря, а не на предыдущий месяц
--     с продажами. Это принципиально: MoM должен учитывать нулевые месяцы.
--   • При previous = 0 рост не определён; NULLIF даёт NULL без division by zero.
--   • 100.0 переводит вычисление в numeric, ROUND фиксирует два знака.
--   • created_at::date использует часовой пояс сессии; в продакшене зону
--     лучше фиксировать явно.
-- =============================================================================

WITH months AS (
    SELECT generate_series(
        TIMESTAMP '2024-01-01 00:00:00',
        TIMESTAMP '2024-12-01 00:00:00',
        INTERVAL '1 month'
    )::date AS month_start
),
monthly AS (
    SELECT
        m.month_start,
        COALESCE(sum(o.total_amount), 0::numeric) AS revenue
    FROM months m
    LEFT JOIN orders o
           ON o.created_at::date >= m.month_start
          AND o.created_at::date < (m.month_start + INTERVAL '1 month')::date
          AND o.status = 'delivered'
    GROUP BY m.month_start
),
with_previous AS (
    SELECT
        month_start,
        revenue,
        lag(revenue) OVER (ORDER BY month_start) AS previous_month_revenue
    FROM monthly
)
SELECT
    month_start AS month,
    revenue,
    previous_month_revenue,
    round(
        100.0 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_pct
FROM with_previous
ORDER BY month ASC;
