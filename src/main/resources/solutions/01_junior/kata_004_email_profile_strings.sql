-- =============================================================================
-- KATA 004 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • lower(email) нормализует адрес для будущих сверок.
--   • split_part(email, '@', 2) извлекает домен без регулярных выражений:
--     формат email гарантирован схемой, поэтому этого достаточно.
--   • char_length считает именно символы UTF-8, а не байты (octet_length),
--     что важно для имён/punycode-доменов.
--   • Алиас email_domain одновременно используется в ORDER BY — PostgreSQL
--     разрешает сортировку по выходному имени.
--   • Фильтр по status/country SARGable и может опираться на составной индекс
--     users(country, status).
-- =============================================================================

SELECT
    user_id,
    lower(email)                    AS email_normalized,
    split_part(email, '@', 2)       AS email_domain,
    upper(full_name)                AS full_name_upper,
    char_length(full_name)          AS full_name_length
FROM users
WHERE status = 'active'
  AND country = 'RU'
ORDER BY email_domain ASC, user_id ASC;
