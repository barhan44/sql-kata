-- =============================================================================
-- KATA 101 · Эталонное решение
-- =============================================================================
-- EXPLAIN-анализ:
--   План использует Bitmap Index Scan по events_big_user_status_idx для
--   диапазона user_id 1..10, затем HashAggregate по user_id и соединение с
--   users. В отличие от исходного запроса, нет трёх InitPlan/SubPlan на
--   каждого пользователя: агрегат по большой таблице строится один раз.
--   В зависимости от статистики PostgreSQL может выбрать Hash Join или
--   Nested Loop, но число агрегатных подпланов не растёт с N.
--
-- Почему так:
--   • events_big агрегируется один раз для всех 10 клиентов. Вместо
--     N+1 подзапросов (по одному проходу на каждую метрику и клиента) получаем
--     один GroupAggregate/HashAggregate.
--   • FILTER (WHERE status='FAILED') и FILTER (WHERE status='PAID') считают
--     метрики в одном проходе. Это дешевле трёх независимых запросов.
--   • LEFT JOIN сохраняет клиентов без событий. COALESCE превращает NULL
--     в 0 для count/sum.
--   • Диапазон user_id BETWEEN 1 AND 10 стоит в CTE: агрегируем только нужных
--     клиентов. На больших таблицах индекс (user_id, status) помогает
--     отфильтровать строки до агрегации.
--   • В реальном приложении N+1 обычно решают одним batch-запросом или
--     загрузкой агрегатов в кэш; SQL с коррелированными подзапросами — не
--     единственный источник проблемы.
-- =============================================================================

WITH event_stats AS (
    SELECT
        e.user_id,
        count(*) AS total_events,
        count(*) FILTER (WHERE e.status = 'FAILED') AS failed_events,
        COALESCE(
            sum(e.amount) FILTER (WHERE e.status = 'PAID'),
            0::numeric
        ) AS paid_amount
    FROM events_big e
    WHERE e.user_id BETWEEN 1 AND 10
    GROUP BY e.user_id
)
SELECT
    u.user_id,
    u.full_name,
    COALESCE(s.total_events, 0::bigint) AS total_events,
    COALESCE(s.failed_events, 0::bigint) AS failed_events,
    COALESCE(s.paid_amount, 0::numeric) AS paid_amount
FROM users u
LEFT JOIN event_stats s ON s.user_id = u.user_id
WHERE u.user_id BETWEEN 1 AND 10
ORDER BY u.user_id ASC;
