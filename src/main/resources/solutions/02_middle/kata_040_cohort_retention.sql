-- =============================================================================
-- KATA 040 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • cohorts фиксирует месяц регистрации и ограничивает анализ 2024 годом,
--     потому что заказы в датасете относятся к январю–июню 2024.
--   • activity разворачивает заказы в пары «когорта + пользователь + месяц»
--     и сразу считает календарный offset в месяцах. DISTINCT не позволяет
--     нескольким заказам одного месяца посчитать пользователя дважды.
--   • retained агрегирует по когорте условными FILTER-счётчиками.
--   • LEFT JOIN к cohort_sizes сохраняет когорты без активности; COALESCE
--     превращает отсутствующие счётчики в 0.
--   • 100.0 и NULLIF дают безопасный процент с двумя знаками.
--   • Для больших когортных отчётов полезна денормализованная колонка
--     registration_month в users или индекс по (user_id, created_at) в orders.
-- =============================================================================

WITH cohorts AS (
    SELECT
        user_id,
        date_trunc('month', registered_at)::date AS cohort_month
    FROM users
    WHERE registered_at >= TIMESTAMPTZ '2024-01-01 00:00:00+03'
      AND registered_at <  TIMESTAMPTZ '2024-07-01 00:00:00+03'
),
cohort_sizes AS (
    SELECT
        cohort_month,
        count(*) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
),
activity AS (
    SELECT DISTINCT
        c.cohort_month,
        c.user_id,
        (
            (extract(year FROM date_trunc('month', o.created_at)::date)::integer
             - extract(year FROM c.cohort_month)::integer) * 12
            + extract(month FROM date_trunc('month', o.created_at)::date)::integer
            - extract(month FROM c.cohort_month)::integer
        ) AS month_offset
    FROM cohorts c
    JOIN orders o ON o.user_id = c.user_id
),
retained AS (
    SELECT
        cohort_month,
        count(*) FILTER (WHERE month_offset = 0) AS month_1_active,
        count(*) FILTER (WHERE month_offset = 1) AS month_2_active,
        count(*) FILTER (WHERE month_offset = 2) AS month_3_active
    FROM activity
    WHERE month_offset BETWEEN 0 AND 2
    GROUP BY cohort_month
)
SELECT
    s.cohort_month,
    s.cohort_size,
    COALESCE(r.month_1_active, 0::bigint) AS month_1_active,
    COALESCE(r.month_2_active, 0::bigint) AS month_2_active,
    COALESCE(r.month_3_active, 0::bigint) AS month_3_active,
    round(
        100.0 * COALESCE(r.month_1_active, 0::bigint)
        / NULLIF(s.cohort_size, 0),
        2
    ) AS month_1_retention_pct,
    round(
        100.0 * COALESCE(r.month_2_active, 0::bigint)
        / NULLIF(s.cohort_size, 0),
        2
    ) AS month_2_retention_pct,
    round(
        100.0 * COALESCE(r.month_3_active, 0::bigint)
        / NULLIF(s.cohort_size, 0),
        2
    ) AS month_3_retention_pct
FROM cohort_sizes s
LEFT JOIN retained r ON r.cohort_month = s.cohort_month
ORDER BY s.cohort_month ASC;
