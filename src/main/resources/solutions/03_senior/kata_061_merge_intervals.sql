-- =============================================================================
-- KATA 061 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Сортируем интервалы по start_date и считаем накопительный максимум
--     end_date только по предыдущим строкам.
--   • Если start_date <= максимального предыдущего конца, интервал пересекается
--     с уже открытым диапазоном и не начинает новую группу. Строгое
--     end_date + 1 = start_date (соседние дни) групп не объединяет.
--   • Начало нового диапазона — флаг 1; накопительная сумма флагов даёт
--     стабильный номер группы. Затем MIN/MAX сворачивают каждую группу.
--   • Это линейный проход после сортировки, без рекурсивного CTE и без
--     самосоединения по всем пересечениям.
--   • Индекс user_subscriptions(user_id, start_date, end_date) поддерживает
--     порядок внутри партиции.
-- =============================================================================

WITH ordered AS (
    SELECT
        s.user_id,
        s.start_date,
        s.end_date,
        max(s.end_date) OVER (
            PARTITION BY s.user_id
            ORDER BY s.start_date, s.end_date, s.subscription_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS previous_max_end,
        CASE
            WHEN s.start_date <= max(s.end_date) OVER (
                PARTITION BY s.user_id
                ORDER BY s.start_date, s.end_date, s.subscription_id
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ) THEN 0
            ELSE 1
        END AS starts_new_interval
    FROM user_subscriptions s
),
grouped AS (
    SELECT
        *,
        sum(starts_new_interval) OVER (
            PARTITION BY user_id
            ORDER BY start_date, end_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS interval_group
    FROM ordered
)
SELECT
    g.user_id,
    u.full_name,
    min(g.start_date) AS merged_from,
    max(g.end_date) AS merged_to,
    count(*) AS source_periods
FROM grouped g
JOIN users u ON u.user_id = g.user_id
GROUP BY g.user_id, u.full_name, g.interval_group
ORDER BY g.user_id ASC, merged_from ASC;
