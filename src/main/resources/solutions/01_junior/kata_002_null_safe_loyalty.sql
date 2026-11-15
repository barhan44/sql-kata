-- =============================================================================
-- KATA 002 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • IS DISTINCT FROM — NULL-безопасное сравнение. Выражение
--     loyalty_tier IS DISTINCT FROM 'bronze' истинно и для NULL, и для любого
--     уровня, кроме bronze. Альтернативу «<> 'bronze' OR IS NULL» писать
--     не нужно.
--   • COALESCE даёт презентационное значение, но не меняет данные в таблице.
--     Псевдонимы фиксируют контракт выходных колонок.
--   • Фильтр по status активен; IN-список здесь не нужен.
-- =============================================================================

SELECT
    user_id,
    full_name,
    COALESCE(phone, 'phone not provided') AS phone_display,
    COALESCE(loyalty_tier, 'no tier')     AS loyalty_display
FROM users
WHERE status = 'active'
  AND loyalty_tier IS DISTINCT FROM 'bronze'
ORDER BY user_id ASC;
