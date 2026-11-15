-- =============================================================================
-- KATA 085 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • jsonb_path_exists проверяет существование хотя бы одного элемента,
--     удовлетворяющего фильтру, и может использовать GIN(jsonb_ops).
--   • jsonb_path_query_array возвращает все дорогие items одним JSON-массивом.
--     Это компактнее, чем разворачивать весь документ и собирать обратно.
--   • Фильтр '@.price > 30000' применяется к каждому элементу items.
--     Порог — число, поэтому JSON-число сравнивается без приведения к text.
--   • expensive_total считается по уже отфильтрованному массиву; для
--     корректности используются price и qty из JSON.
--   • GIN-индекс по document помогает в общем случае; для конкретного
--     JSONPath PostgreSQL 16 не всегда умеет извлечь предикат из индекса,
--     поэтому на очень больших данных полезны generated columns или
--     jsonb_path_ops-запросы на основе containment.
-- =============================================================================

WITH expensive AS (
    SELECT
        c.cart_id,
        c.user_id,
        jsonb_path_query_array(
            c.document,
            '$.items[*] ? (@.price > 30000)'
        ) AS expensive_items
    FROM shopping_carts c
    WHERE jsonb_path_exists(
        c.document,
        '$.items[*] ? (@.price > 30000)'
    )
)
SELECT
    cart_id,
    user_id,
    expensive_items,
    jsonb_array_length(expensive_items) AS expensive_items_count,
    COALESCE(
        (
            SELECT sum((item ->> 'price')::numeric * (item ->> 'qty')::numeric)
            FROM jsonb_array_elements(expensive_items) AS item
        ),
        0::numeric
    ) AS expensive_total
FROM expensive
ORDER BY cart_id ASC;
