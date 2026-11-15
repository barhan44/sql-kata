-- =============================================================================
-- KATA 035 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Окно с кадром ... AND 1 PRECEDING смотрит только на прошлые заказы
--     и никогда не включает текущий. Поэтому среднее не «размывается»
--     аномалией, которую мы ищем.
--   • Для первой строки раздела COUNT(*) по пустому кадру = 0, AVG = NULL.
--     Фильтр previous_orders_count > 0 отсекает такие строки до сравнения.
--   • Условие total_amount > 2 * previous_avg_amount строгое: ровно двойное
--     превышение не считается аномалией.
--   • ROUND(...,4) только для читаемого коэффициента; фильтрация выполняется
--     по точным numeric-значениям. Четырёх знаков достаточно, чтобы отличить
--     «чуть больше 2x» от ровно двукратного превышения.
--   • COUNT/AVG с явным ROWS не зависят от RANGE-семантики при одинаковом
--     created_at. order_id — tie-breaker для порядка.
-- =============================================================================

WITH history AS (
    SELECT
        o.user_id,
        u.full_name,
        o.order_id,
        o.created_at,
        o.total_amount,
        count(*) OVER (
            PARTITION BY o.user_id
            ORDER BY o.created_at, o.order_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS previous_orders_count,
        avg(o.total_amount) OVER (
            PARTITION BY o.user_id
            ORDER BY o.created_at, o.order_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS previous_avg_amount
    FROM orders o
    JOIN users u ON u.user_id = o.user_id
)
SELECT
    user_id,
    full_name,
    order_id,
    created_at,
    total_amount,
    previous_orders_count,
    previous_avg_amount,
    round(total_amount / NULLIF(previous_avg_amount, 0), 4) AS ratio_to_previous_avg
FROM history
WHERE previous_orders_count > 0
  AND total_amount > 2 * previous_avg_amount
ORDER BY user_id ASC, created_at ASC, order_id ASC;
