-- =============================================================================
-- KATA 104 · Эталонное решение
-- =============================================================================
-- EXPLAIN-анализ:
--   На текущем объёме PostgreSQL выбирает Hash Right Anti Join между
--   audit_logs и users (на больших таблицах возможен Anti Join по индексу
--   actor_user_id). Главное — NOT EXISTS не нуждается в полном списке
--   значений и корректно обрабатывает NULL: строки с actor_user_id IS NULL
--   просто не являются акторами.
--
-- Почему так:
--   • NOT EXISTS оценивает для каждого пользователя только факт отсутствия
--     строки и полностью игнорирует NULL в actor_user_id. Строки с NULL не
--     являются акторами и не должны влиять на ответ.
--   • NOT IN (SELECT actor_user_id ...) — ловушка: x NOT IN (NULL, ...)
--     эквивалентно x<>NULL AND ..., первое даёт UNKNOWN, и результат пуст.
--   • Anti-join через LEFT JOIN + IS NULL тоже корректен, но NOT EXISTS
--     читается ближе к формулировке и не требует выбирать правые колонки.
--   • На больших audit_logs полезны индексы по actor_user_id; PostgreSQL
--     может выбрать Hash Anti Join или Anti Join с индексом.
--   • Можно дополнительно отфильтровать a.actor_user_id IS NOT NULL, но
--     NOT EXISTS в этом не нуждается.
-- =============================================================================

SELECT
    u.user_id,
    u.full_name,
    u.email
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM audit_logs a
    WHERE a.actor_user_id = u.user_id
)
ORDER BY u.user_id ASC;
