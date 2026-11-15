-- =============================================================================
-- KATA 039 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • purchasers строит множество пар (user_id, category_id) по доставленным
--     заказам. DISTINCT сразу убирает повторные покупки одного пользователя.
--   • EXCEPT вычисляет разность множеств: покупатели смартфонов минус
--     покупатели аудио. Дубликаты удаляются автоматически.
--   • Это читается ближе к бизнес-формулировке, чем коррелированный
--     NOT EXISTS, и хорошо работает на небольших множествах.
--   • NOT EXISTS тоже корректен и часто эффективнее при индексах:
--       WHERE p.category_id = 2
--         AND NOT EXISTS (... category_id = 4 ...)
--     NOT IN по подзапросу с потенциальным NULL опасен: NULL в списке
--     превращает отрицание в UNKNOWN.
--   • Финальный JOIN нужен только для имён и email; он идёт после
--     сокращения множества, поэтому не размножает строки.
-- =============================================================================

WITH purchasers AS (
    SELECT DISTINCT
        o.user_id,
        p.category_id
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.status = 'delivered'
      AND p.category_id IN (2, 4)
),
smartphone_only AS (
    SELECT user_id
    FROM purchasers
    WHERE category_id = 2
    EXCEPT
    SELECT user_id
    FROM purchasers
    WHERE category_id = 4
)
SELECT
    u.user_id,
    u.full_name,
    u.email
FROM users u
JOIN smartphone_only s ON s.user_id = u.user_id
ORDER BY u.user_id ASC;
