-- =============================================================================
-- KATA 053 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • annual_spend агрегирует доставленные заказы фиксированного 2024 года.
--     now()/current_date не используются: датасет заморожен, а отчёт должен
--     быть воспроизводим в любом году.
--   • UPDATE ... FROM — массовое обновление одним оператором. Условие
--     u.user_id = s.user_id соединяет целевую таблицу с агрегатом.
--   • CASE задаёт ровно четыре уровня с явными порогами. Порог — «больше
--     или равно», поэтому граничные суммы попадают в старший уровень.
--   • UPDATE затрагивает только пользователей, найденных в annual_spend.
--     Клиенты без доставленных заказов не обнуляют свой текущий уровень.
--   • RETURNING возвращает новые значения target-таблицы и агрегаты из
--     FROM-отношения. CTE позволяет отсортировать результат.
--   • В продакшене массовое обновление стоит выполнять батчами и учитывать
--     блокировки; в трейнинге объём маленький, а транзакция откатывается.
-- =============================================================================

WITH annual_spend AS (
    SELECT
        user_id,
        count(*) AS delivered_orders,
        sum(total_amount) AS total_spent
    FROM orders
    WHERE status = 'delivered'
      AND created_at >= TIMESTAMPTZ '2024-01-01 00:00:00+03'
      AND created_at <  TIMESTAMPTZ '2025-01-01 00:00:00+03'
    GROUP BY user_id
),
updated AS (
    UPDATE users u
       SET loyalty_tier = CASE
               WHEN s.total_spent >= 150000 THEN 'platinum'
               WHEN s.total_spent >= 80000  THEN 'gold'
               WHEN s.total_spent >= 35000  THEN 'silver'
               ELSE 'bronze'
           END
      FROM annual_spend s
     WHERE u.user_id = s.user_id
    RETURNING
        u.user_id,
        u.full_name,
        u.loyalty_tier,
        s.total_spent,
        s.delivered_orders
)
SELECT
    user_id,
    full_name,
    loyalty_tier,
    total_spent,
    delivered_orders
FROM updated
ORDER BY user_id ASC;
