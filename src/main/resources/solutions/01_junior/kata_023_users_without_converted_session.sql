-- =============================================================================
-- KATA 023 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • NOT EXISTS проверяет отсутствие подходящей сессии для каждого
--     пользователя и корректно возвращает TRUE, даже если в user_sessions
--     есть NULL. NULL-значения в подзапросе его не ломают.
--   • Почему NOT IN здесь опасен:
--       SELECT ... WHERE user_id NOT IN (
--           SELECT conversion_order_id FROM user_sessions
--       )
--     В списке есть NULL. Сравнение x NOT IN (NULL, 5) эквивалентно
--     x <> NULL AND x <> 5. Первое даёт UNKNOWN, поэтому NOT IN не выбирает
--     ни одной строки. Это классическая ловушка трёхзначной логики.
--   • Индекс sessions_conversions_idx — частичный по NOT NULL
--     conversion_order_id; для NOT EXISTS полезен также индекс по user_id.
--   • Пользователь без сессий тоже проходит NOT EXISTS и попадает в результат.
-- =============================================================================

SELECT
    u.user_id,
    u.full_name,
    u.email
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM user_sessions s
    WHERE s.user_id = u.user_id
      AND s.conversion_order_id IS NOT NULL
)
ORDER BY u.user_id ASC;
