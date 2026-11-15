-- =============================================================================
-- KATA 086 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • `document - 'debug'` удаляет ключ верхнего уровня.
--   • `#- '{payment,card_token}'` удаляет ключ по вложенному пути.
--   • `||` сливает два JSONB-объекта; правый объект имеет приоритет при
--     совпадении ключей. Здесь добавляется processed=true.
--   • jsonb_set с create_missing=true обновляет вложенный путь только тогда,
--     когда родительский объект summary уже существует. Поэтому summary={}
--     добавляется через слияние, а затем jsonb_set кладёт items_count.
--     Длина считается по исходному document, а не по уже очищенному:
--     удалённые служебные данные не должны менять бизнес-метрику.
--   • DISTINCT ON выбирает последнюю корзину пользователя, а отдельный
--     агрегат собирает все cart_id. Две агрегации нельзя смешивать в одном
--     GROUP BY без потери детализации latest.
--   • JSONB-операторы возвращают новый документ; исходные данные не меняются
--     (в отличие от UPDATE ... jsonb_set). Задача возвращает проекцию для API.
-- =============================================================================

WITH latest AS (
    SELECT DISTINCT ON (user_id)
        user_id,
        cart_id,
        document
    FROM shopping_carts
    ORDER BY user_id ASC, created_at DESC, cart_id DESC
),
aggregated AS (
    SELECT
        user_id,
        count(*) AS carts_count,
        jsonb_agg(cart_id ORDER BY created_at, cart_id) AS cart_ids
    FROM shopping_carts
    GROUP BY user_id
)
SELECT
    a.user_id,
    a.carts_count,
    a.cart_ids,
    jsonb_set(
        (
            (l.document - 'debug') #- '{payment,card_token}'
        ) || '{"processed": true, "summary": {}}'::jsonb,
        '{summary,items_count}',
        to_jsonb(jsonb_array_length(l.document -> 'items')),
        true
    ) AS sanitized_document
FROM aggregated a
JOIN latest l ON l.user_id = a.user_id
ORDER BY a.user_id ASC;
