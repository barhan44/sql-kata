-- =============================================================================
-- KATA 017 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Условие o.status = 'delivered' находится в ON. Это принципиально:
--     в WHERE оно отбросило бы пользователей без доставленных заказов
--     и превратило LEFT JOIN в INNER JOIN.
--   • COUNT(DISTINCT u.user_id) защищает от размножения пользователя
--     при нескольких заказах.
--   • COALESCE(SUM(o.total_amount), 0) возвращает numeric 0 для уровней
--     без доставленных заказов, а AVG остаётся NULL — среднее по пустому
--     множеству не определено.
--   • COALESCE(loyalty_tier, 'no tier') используется и в SELECT, и в
--     GROUP BY через позицию 1, чтобы не дублировать выражение.
--   • Индексы users(user_id) (PK) и orders(user_id, status) ускоряют join.
-- =============================================================================

SELECT
    COALESCE(u.loyalty_tier, 'no tier') AS loyalty_tier,
    count(DISTINCT u.user_id) AS users_count,
    count(o.order_id) AS delivered_orders,
    COALESCE(sum(o.total_amount), 0) AS delivered_revenue,
    round(avg(o.total_amount), 2) AS avg_order_value
FROM users u
LEFT JOIN orders o
       ON o.user_id = u.user_id
      AND o.status = 'delivered'
GROUP BY 1
ORDER BY loyalty_tier ASC;
