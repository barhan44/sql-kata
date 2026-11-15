-- =============================================================================
-- KATA 059 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • ordered добавляет предыдущее событие через LAG. Порядок
--     occurred_at + event_id полностью детерминирован.
--   • flagged ставит 1 в начале новой сессии: первого события или разрыва
--     строго больше 30 минут. Ровно 30 минут остаётся в текущей сессии.
--   • Накопительная сумма флага превращает поток в номер сессии.
--   • Группировка по user_id, session_number сворачивает события в интервал.
--     Длительность считается от первого до последнего события; для одного
--     события она равна 0.
--   • Индекс user_events(user_id, occurred_at) помогает читать поток в нужном
--     порядке. Для очень больших потоков полезна материализация сессий
--     инкрементально, но здесь важна логика окон.
-- =============================================================================

WITH ordered AS (
    SELECT
        e.user_id,
        u.full_name,
        e.event_id,
        e.occurred_at,
        lag(e.occurred_at) OVER (
            PARTITION BY e.user_id
            ORDER BY e.occurred_at, e.event_id
        ) AS previous_event_at
    FROM user_events e
    JOIN users u ON u.user_id = e.user_id
),
flagged AS (
    SELECT
        *,
        CASE
            WHEN previous_event_at IS NULL
              OR occurred_at - previous_event_at > INTERVAL '30 minutes'
            THEN 1
            ELSE 0
        END AS new_session_flag
    FROM ordered
),
sessionized AS (
    SELECT
        *,
        sum(new_session_flag) OVER (
            PARTITION BY user_id
            ORDER BY occurred_at, event_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS session_number
    FROM flagged
)
SELECT
    user_id,
    full_name,
    session_number,
    min(occurred_at) AS session_started_at,
    max(occurred_at) AS session_ended_at,
    count(*) AS event_count,
    round(
        extract(epoch FROM (max(occurred_at) - min(occurred_at))) / 60.0,
        1
    ) AS session_minutes
FROM sessionized
GROUP BY user_id, full_name, session_number
ORDER BY user_id ASC, session_number ASC;
