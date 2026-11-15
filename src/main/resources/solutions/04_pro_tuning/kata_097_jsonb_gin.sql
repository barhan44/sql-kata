-- =============================================================================
-- KATA 097 · Эталонное решение
-- =============================================================================
-- EXPLAIN (ANALYZE): Bitmap Index Scan on events_big_metadata_gin_idx
--   -> Bitmap Heap Scan events_big (2666 rows) -> HashAggregate -> Sort.
-- Seq Scan по events_big отсутствует.
--
-- Почему так:
--   • @> — оператор containment, для которого GIN(jsonb_ops) может найти
--     записи по вложенным ключам без вычисления ->> для каждой строки.
--   • Предикат metadata @> '{"type":"PAYMENT","currency":"USD"}' требует
--     наличия обоих ключей с точными значениями. Дополнительные ключи
--     (channel, attempt) не мешают.
--   • GIN может вернуть bitmap TID; PostgreSQL читает heap только для
--     подходящих строк, а затем агрегирует статусы.
--   • GIN(jsonb_path_ops) был бы компактнее, но индексировал бы только
--     containment-пути; jsonb_ops универсальнее.
--   • Запрос с двумя ->> не эквивалентен по производительности: выражения
--     по ключам не поддержаны этим GIN-индексом. Результат отличается только
--     способом доступа; значения в metadata одинаковы.
-- =============================================================================

SELECT
    status,
    count(*) AS events_count
FROM events_big
WHERE metadata @> '{"type":"PAYMENT","currency":"USD"}'::jsonb
GROUP BY status
ORDER BY status ASC;
