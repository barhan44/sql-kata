-- =============================================================================
-- KATA 030 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • LEAD смотрит на следующую строку окна, не удаляя текущую. Это позволяет
--     в одной строке показать текущую сессию и прогноз следующего входа.
--   • Порядок started_at + session_id детерминирован: в один день у клиента
--     может быть несколько сессий.
--   • Анонимные сессии исключены до окна: иначе они образовали бы общий
--     раздел NULL и «следующая сессия» не имела бы бизнес-смысла.
--   • Длительность и пауза считаются через EPOCH, деление на 60.0 даёт
--     минуты с десятичной частью. Для последней сессии next_start = NULL,
--     поэтому minutes_until_next_session тоже NULL.
--   • На больших данных индекс (user_id, started_at) помогает выполнить
--     WindowAgg без полной сортировки.
-- =============================================================================

WITH session_forecast AS (
    SELECT
        s.session_id,
        s.user_id,
        u.full_name,
        s.started_at,
        s.ended_at,
        round(
            extract(epoch FROM (s.ended_at - s.started_at)) / 60.0,
            1
        ) AS session_minutes,
        lead(s.started_at) OVER (
            PARTITION BY s.user_id
            ORDER BY s.started_at, s.session_id
        ) AS next_session_started_at
    FROM user_sessions s
    JOIN users u ON u.user_id = s.user_id
    WHERE s.user_id IS NOT NULL
)
SELECT
    session_id,
    user_id,
    full_name,
    started_at,
    ended_at,
    session_minutes,
    next_session_started_at,
    round(
        extract(epoch FROM (next_session_started_at - ended_at)) / 60.0,
        1
    ) AS minutes_until_next_session
FROM session_forecast
ORDER BY user_id ASC, started_at ASC, session_id ASC;
