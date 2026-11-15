-- =============================================================================
-- KATA 065 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Классическая задача о событиях: начало сессии +1, конец -1.
--   • Сначала группируем события с одинаковым timestamp и суммируем дельты
--     ДО накопления. Это делает обработку одновременного закрытия/открытия
--     детерминированной и не зависит от порядка строк.
--   • Затем SUM(delta) OVER (ORDER BY timestamp ROWS ...) даёт число
--     открытых сессий после каждого события.
--   • Пик выбирается сортировкой по убыванию количества и возрастанию времени.
--     LIMIT 1 даёт самый ранний момент достижения максимума.
--   • NULL ended_at учитывается как незакрытая сессия: +1 без -1.
--   • Индексы по started_at/ended_at в схеме отсутствуют, но для больших
--     таблиц полезен btree по обоим полям или отдельные покрывающие индексы.
-- =============================================================================

WITH events AS (
    SELECT started_at AS event_at, 1 AS delta
    FROM user_sessions
    UNION ALL
    SELECT ended_at AS event_at, -1 AS delta
    FROM user_sessions
    WHERE ended_at IS NOT NULL
),
grouped AS (
    SELECT
        event_at,
        sum(delta) AS delta
    FROM events
    GROUP BY event_at
),
running AS (
    SELECT
        event_at,
        sum(delta) OVER (
            ORDER BY event_at
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS concurrent_sessions
    FROM grouped
)
SELECT
    event_at AS peak_at,
    concurrent_sessions AS peak_sessions
FROM running
ORDER BY concurrent_sessions DESC, event_at ASC
LIMIT 1;
