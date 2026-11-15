-- =============================================================================
-- KATA 056 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Календарь начинается 26 мая, чтобы для 1 июня окно уже содержало шесть
--     предшествующих дней. В результат попадают только дни июня.
--   • RANGE определяет границы окна по значению ORDER BY (дате), а не по
--     числу строк. Поэтому окно — именно 7 календарных дней, даже если в
--     источнике есть пропуски.
--   • ROWS BETWEEN 6 PRECEDING AND CURRENT ROW взяло бы 7 предыдущих СТРОК.
--     Если источник не заполнен нулями, это были бы 7 дат с продажами, а не
--     7 календарных дней, и промежуток между ними мог быть месяцем.
--   • В этом решении календарь заполнен всеми днями и нулями, поэтому
--     финансовая средняя корректно учитывает дни без выручки. Даже при полном
--     календаре RANGE остаётся выразительнее: он фиксирует контракт «7 дней».
--   • ORDER BY sale_date::timestamp нужен, чтобы PostgreSQL применял
--     интервальный RANGE-offset; тип date сам по себе не даёт интервальной
--     арифметики в границах фрейма.
--   • Индекс orders(created_at) помогает фильтру по календарному дню.
-- =============================================================================

WITH calendar AS (
    SELECT generate_series(
        TIMESTAMP '2024-05-26 00:00:00',
        TIMESTAMP '2024-06-30 00:00:00',
        INTERVAL '1 day'
    )::date AS sale_date
),
daily AS (
    SELECT
        c.sale_date,
        COALESCE(sum(o.total_amount), 0::numeric) AS daily_revenue
    FROM calendar c
    LEFT JOIN orders o
           ON o.created_at::date = c.sale_date
          AND o.status = 'delivered'
    GROUP BY c.sale_date
),
rolling AS (
    SELECT
        sale_date,
        daily_revenue,
        round(
            avg(daily_revenue) OVER (
                ORDER BY sale_date::timestamp
                RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW
            ),
            2
        ) AS rolling_7d_avg
    FROM daily
)
SELECT
    sale_date,
    daily_revenue,
    rolling_7d_avg
FROM rolling
WHERE sale_date >= DATE '2024-06-01'
ORDER BY sale_date ASC;
