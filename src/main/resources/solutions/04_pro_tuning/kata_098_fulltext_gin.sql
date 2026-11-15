-- =============================================================================
-- KATA 098 · Эталонное решение
-- =============================================================================
-- EXPLAIN (ANALYZE): Bitmap Index Scan on events_big_search_gin_idx
--   -> Bitmap Heap Scan (200 rows) -> HashAggregate -> Sort.
-- Seq Scan по events_big отсутствует.
--
-- Почему так:
--   • search_vector предвычислен при вставке через to_tsvector('simple',
--     description), поэтому запросу не нужно разбирать текст на лету.
--   • Оператор @@ проверяет tsvector на совпадение с tsquery; GIN-индекс
--     хранит лексемы и позволяет найти только строки с 'failed'.
--   • Конфигурация 'simple' не применяет stemming/стоп-слова и не зависит от
--     языковых словарей. Это делает тест детерминированным, но не подходит
--     для естественного языка без нормализации.
--   • ILIKE '%failed%' не использует B-Tree и читает все строки; в больших
--     таблицах это принципиальная разница.
--   • Для production лучше хранить generated column:
--       search_vector tsvector GENERATED ALWAYS AS
--       (to_tsvector('english', description)) STORED
--     но в тренировке поле заполняется в seed, чтобы план был стабильным.
-- =============================================================================

SELECT
    status,
    count(*) AS events_count
FROM events_big
WHERE search_vector @@ to_tsquery('simple', 'failed')
GROUP BY status
ORDER BY status ASC;
