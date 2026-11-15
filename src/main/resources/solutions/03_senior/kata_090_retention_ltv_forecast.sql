-- =============================================================================
-- KATA 090 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • cohort_calendar через WITH RECURSIVE создаёт 6 календарных месяцев
--     жизни для каждой когорты. Это позволяет показать и месяцы без активности.
--   • cohort_users использует LATERAL для поиска min(created_at) — первой
--     покупки пользователя. activated_users — число клиентов с непустым
--     первым заказом; LATERAL даёт эту метрику без коррелированного подзапроса
--     в SELECT.
--   • monthly join связывает каждого пользователя когорты с заказами за
--     конкретный period_month. COUNT(DISTINCT user_id) даёт активность,
--     FILTER по delivered — сумму выручки.
--   • cumulative_revenue — оконная сумма по month_index, то есть накопительный
--     LTV когорты. cumulative_ltv_per_user делит его на размер когорты.
--   • projected_12m_ltv — простая annualization: средняя месячная выручка на
--     пользователя за наблюдённые месяцы × 12. Это не ML-прогноз, а понятная
--     базовая линия; для реального прогноза нужно учитывать сезонность,
--     churn и распределение по каналам.
--   • Индекс orders(user_id, created_at) ускоряет LATERAL, а
--     user_events/orders(user_id, created_at) — последующие аналитические
--     срезы.
-- =============================================================================

WITH RECURSIVE cohort_calendar AS (
    SELECT
        c.cohort_month,
        c.cohort_month AS period_month,
        0 AS month_index
    FROM (
        SELECT DISTINCT
            date_trunc('month', u.registered_at)::date AS cohort_month
        FROM users u
        WHERE u.registered_at >= TIMESTAMPTZ '2024-01-01 00:00:00+03'
          AND u.registered_at <  TIMESTAMPTZ '2024-07-01 00:00:00+03'
    ) c

    UNION ALL

    SELECT
        cc.cohort_month,
        (cc.period_month + INTERVAL '1 month')::date,
        cc.month_index + 1
    FROM cohort_calendar cc
    WHERE cc.month_index < 5
),
cohort_users AS (
    SELECT
        u.user_id,
        date_trunc('month', u.registered_at)::date AS cohort_month,
        first_order.first_order_at
    FROM users u
    CROSS JOIN LATERAL (
        SELECT min(o.created_at) AS first_order_at
        FROM orders o
        WHERE o.user_id = u.user_id
    ) first_order
    WHERE u.registered_at >= TIMESTAMPTZ '2024-01-01 00:00:00+03'
      AND u.registered_at <  TIMESTAMPTZ '2024-07-01 00:00:00+03'
),
cohort_stats AS (
    SELECT
        cohort_month,
        count(*) AS cohort_size,
        count(first_order_at) AS activated_users
    FROM cohort_users
    GROUP BY cohort_month
),
monthly AS (
    SELECT
        cc.cohort_month,
        cc.month_index,
        cc.period_month,
        count(DISTINCT CASE WHEN o.order_id IS NOT NULL THEN cu.user_id END)
            AS active_users,
        COALESCE(
            sum(o.total_amount) FILTER (WHERE o.status = 'delivered'),
            0::numeric
        ) AS monthly_revenue
    FROM cohort_calendar cc
    JOIN cohort_users cu ON cu.cohort_month = cc.cohort_month
    LEFT JOIN orders o
           ON o.user_id = cu.user_id
          AND date_trunc('month', o.created_at)::date = cc.period_month
    GROUP BY cc.cohort_month, cc.month_index, cc.period_month
),
with_cumulative AS (
    SELECT
        m.*,
        cs.cohort_size,
        cs.activated_users,
        sum(m.monthly_revenue) OVER (
            PARTITION BY m.cohort_month
            ORDER BY m.month_index
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM monthly m
    JOIN cohort_stats cs ON cs.cohort_month = m.cohort_month
)
SELECT
    cohort_month,
    month_index,
    period_month,
    cohort_size,
    activated_users,
    active_users,
    round(
        100.0 * active_users / NULLIF(cohort_size, 0),
        2
    ) AS retention_pct,
    monthly_revenue,
    cumulative_revenue,
    round(
        cumulative_revenue / NULLIF(cohort_size, 0),
        2
    ) AS cumulative_ltv_per_user,
    round(
        (cumulative_revenue / NULLIF(cohort_size, 0))
        / NULLIF(month_index + 1, 0) * 12,
        2
    ) AS projected_12m_ltv
FROM with_cumulative
ORDER BY cohort_month ASC, month_index ASC;
