-- =============================================================================
-- KATA 033 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Условие o.status = 'delivered' находится в ON, иначе LEFT JOIN стал бы
--     INNER JOIN и клиенты без покупок выпали бы из сегментации.
--   • COALESCE(SUM(...), 0) даёт числовой LTV для клиентов без доставленных
--     заказов; пустая сумма не должна оставаться NULL в бизнес-метрике.
--   • NTILE(4) делит строки максимально ровно (7/6/6/6 для 25 клиентов).
--     При большом количестве одинаковых LTV (например, нулей) граница
--     квартилей проходит внутри группы равных значений — это свойство NTILE,
--     а tie-breaker user_id делает результат воспроизводимым.
--   • Первый квартиль — самая высокая выручка, поэтому ORDER BY LTV DESC.
--   • Индексы users(user_id) и orders(user_id, status) ускоряют LEFT JOIN
--     и агрегацию на больших объёмах.
-- =============================================================================

WITH customer_ltv AS (
    SELECT
        u.user_id,
        u.full_name,
        COALESCE(sum(o.total_amount), 0) AS lifetime_value
    FROM users u
    LEFT JOIN orders o
           ON o.user_id = u.user_id
          AND o.status = 'delivered'
    GROUP BY u.user_id, u.full_name
),
quartiles AS (
    SELECT
        user_id,
        full_name,
        lifetime_value,
        ntile(4) OVER (
            ORDER BY lifetime_value DESC, user_id ASC
        ) AS ltv_quartile
    FROM customer_ltv
)
SELECT
    user_id,
    full_name,
    lifetime_value,
    ltv_quartile,
    ltv_quartile = 1 AS is_vip
FROM quartiles
ORDER BY ltv_quartile ASC, lifetime_value DESC, user_id ASC;
