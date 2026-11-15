-- =============================================================================
-- KATA 052 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • ON CONFLICT (sku) — атомарный UPSERT по бизнес-ключу. При конфликте
--     вставляемая строка доступна как EXCLUDED, поэтому можно взять её
--     price/stock/is_active без повторного SELECT.
--   • Для существующего SKU product_id в RETURNING остаётся старым (1):
--     DO UPDATE не включает product_id и не перезаписывает PK.
--   • CTE с INSERT ... RETURNING позволяет отсортировать результат.
--     Сам INSERT не поддерживает ORDER BY; без CTE порядок строк не гарантирован.
--   • Явные product_id 9001/9002 — учебное исключение из обычной практики.
--     Причина: верификатор запускает кандидата и эталон в отдельных
--     транзакциях с ROLLBACK, а sequence не откатывается. Генерируемые id
--     различались бы между запусками. В продакшене product_id лучше не
--     передавать и позволить identity выдать значение.
--   • После проверки транзакция откатится, поэтому база не изменится.
-- =============================================================================

WITH upserted AS (
    INSERT INTO products (
        product_id,
        sku,
        name,
        category_id,
        price,
        cost,
        stock,
        rating,
        tags,
        attributes,
        is_active,
        created_at
    )
    VALUES
        (
            9001,
            'PHN-IP15',
            'iPhone 15',
            2,
            87990.00,
            70000.00,
            20,
            4.8,
            ARRAY['apple', 'ios', '5g'],
            '{"color":"black","storage_gb":128}'::jsonb,
            true,
            DATE '2023-09-22'
        ),
        (
            9002,
            'MID-KBD9',
            'Middle Mechanical Keyboard',
            1,
            14900.00,
            9000.00,
            6,
            4.7,
            ARRAY['accessory', 'keyboard'],
            '{"layout":"ansi","switches":"brown"}'::jsonb,
            true,
            DATE '2024-07-01'
        )
    ON CONFLICT (sku) DO UPDATE
       SET price = EXCLUDED.price,
           stock = EXCLUDED.stock,
           is_active = EXCLUDED.is_active
    RETURNING *
)
SELECT *
FROM upserted
ORDER BY sku ASC;
