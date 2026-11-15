-- =============================================================================
-- KATA 109 · Эталонное решение
-- =============================================================================
-- EXPLAIN (ANALYZE): Index Only Scan using
--   events_big_merchant_status_created_idx
--   -> Incremental Sort (created_at, event_id) -> WindowAgg.
-- Seq Scan по events_big отсутствует.
--
-- Почему так:
--   • Фильтр по merchant_id, status и диапазону дат выполняется ДО окна.
--     WindowAgg видит 22 строки одной партиции вместо 20 000 событий.
--   • Индекс (merchant_id, status, created_at) INCLUDE (amount, event_id)
--     покрывает фильтр, сортировку и SUM(amount): PostgreSQL идёт по
--     Index Only Scan без heap.
--   • Сортировка по created_at, event_id поддерживается порядком индекса;
--     Incremental Sort досортировывает группы с одинаковым created_at.
--   • Если фильтр оставить снаружи подзапроса, окно считается по всем строкам
--     всех merchant_id, а затем почти всё отбрасывается.
--   • Фильтр до окна также уменьшает перекос данных: одна «тяжёлая» партиция
--     не заставляет обрабатывать все остальные.
-- =============================================================================

WITH filtered AS (
    SELECT
        e.merchant_id,
        e.event_id,
        e.created_at,
        e.amount
    FROM events_big e
    WHERE e.merchant_id = 7
      AND e.status = 'PAID'
      AND e.created_at >= TIMESTAMPTZ '2025-01-01 00:00:00+03'
      AND e.created_at <  TIMESTAMPTZ '2025-07-01 00:00:00+03'
)
SELECT
    merchant_id,
    event_id,
    created_at,
    amount,
    sum(amount) OVER (
        PARTITION BY merchant_id
        ORDER BY created_at, event_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_amount
FROM filtered
ORDER BY created_at ASC, event_id ASC;
