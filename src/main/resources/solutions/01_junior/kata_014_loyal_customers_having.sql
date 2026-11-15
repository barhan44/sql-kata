-- =============================================================================
-- KATA 014 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • WHERE фильтрует строки до агрегации, HAVING — уже агрегированные группы.
--     Условия на COUNT и SUM нельзя переносить в WHERE.
--   • SUM(total_amount) имеет тип numeric, поэтому total_spent остаётся
--     точным денежным значением; ROUND(..., 2) задаёт масштаб.
--   • user_id и full_name включены в GROUP BY; group by user_id был бы
--     достаточен, если бы full_name был функционально зависим, но PostgreSQL
--     разрешает только прямую зависимость от первичного ключа. Явное
--     включение безопаснее и переносимо.
--   • ORDER BY по псевдониму total_spent упрощает запрос и использует уже
--     вычисленное значение.
-- =============================================================================

SELECT
    u.user_id,
    u.full_name,
    count(*) AS delivered_orders,
    round(sum(o.total_amount), 2) AS total_spent
FROM users u
JOIN orders o ON o.user_id = u.user_id
WHERE o.status = 'delivered'
GROUP BY u.user_id, u.full_name
HAVING count(*) >= 2
   AND sum(o.total_amount) >= 50000
ORDER BY total_spent DESC, u.user_id ASC;
