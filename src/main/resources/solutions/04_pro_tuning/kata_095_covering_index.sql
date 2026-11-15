-- =============================================================================
-- KATA 095 · Эталонное решение
-- =============================================================================
-- EXPLAIN (ANALYZE): Index Only Scan using events_big_covering_idx
--   Heap Fetches: 0 (после VACUUM в seed).
-- Seq Scan по events_big отсутствует.
--
-- Почему так:
--   • Covering index создан как (status, created_at) INCLUDE (event_type, amount).
--     Все четыре выбранные колонки присутствуют в индексе: status/created_at
--     в ключе, event_type/amount в INCLUDE.
--   • Запрос не выбирает event_id/description, которых нет в индексе.
--     Именно это превращает план в Index Only Scan.
--   • VACUUM (ANALYZE) в seed заполнил visibility map. При отсутствии
--     актуальной visibility map PostgreSQL всё равно может выбрать Index Only
--     Scan, но будет вынужден проверять heap для видимости (Heap Fetches > 0).
--   • INCLUDE-колонки не участвуют в сортировке B-Tree; они лежат в leaf
--     entries и доступны без heap. Это дешевле, чем включать их в ключ и
--     увеличивать размер внутренних узлов.
--   • ORDER BY использует созданный порядок по created_at и сортирует только
--     группы одинакового created_at (Incremental Sort), поэтому результат
--     детерминирован.
-- =============================================================================

SELECT
    status,
    created_at,
    event_type,
    amount
FROM events_big
WHERE status = 'SHIPPED'
  AND created_at >= TIMESTAMPTZ '2025-05-01 00:00:00+03'
  AND created_at <  TIMESTAMPTZ '2025-07-01 00:00:00+03'
ORDER BY created_at ASC, event_type ASC, amount ASC;
