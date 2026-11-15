-- =============================================================================
-- KATA 048 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • jsonb_array_elements_text разворачивает JSON-массив строк в набор text.
--     Если бы элементы были объектами, понадобился бы
--     jsonb_array_elements и дальнейшее извлечение полей.
--   • CASE с jsonb_typeof защищает от события, где tags — не массив.
--     Вызов set-returning функции на скаляре иначе завершился бы ошибкой.
--   • DISTINCT в expanded делает событие уникальным для каждого тега;
--     агрегат count(*) затем считает именно события, а не повторы тега
--     внутри одного payload.
--   • COUNT(DISTINCT actor_user_id) игнорирует NULL, поэтому системные
--     события с actor_user_id IS NULL не увеличивают число акторов.
--   • Перцентили/статистика по тегам могут использовать GIN-индекс по payload,
--     если добавить фильтр контейнермента; unnest JSON-массива сам по себе
--     требует чтения подходящих строк.
-- =============================================================================

WITH expanded AS (
    SELECT DISTINCT
        a.log_id,
        a.actor_user_id,
        a.occurred_at,
        tag
    FROM audit_logs a
    CROSS JOIN LATERAL jsonb_array_elements_text(
        CASE
            WHEN jsonb_typeof(a.payload -> 'tags') = 'array'
            THEN a.payload -> 'tags'
            ELSE '[]'::jsonb
        END
    ) AS t(tag)
    WHERE jsonb_typeof(a.payload -> 'tags') = 'array'
)
SELECT
    tag,
    count(*) AS events_count,
    count(DISTINCT actor_user_id) AS distinct_actors,
    min(occurred_at) AS first_seen,
    max(occurred_at) AS last_seen
FROM expanded
GROUP BY tag
ORDER BY events_count DESC, tag ASC;
