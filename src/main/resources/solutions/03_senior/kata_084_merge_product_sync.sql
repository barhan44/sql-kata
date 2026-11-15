-- =============================================================================
-- KATA 084 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • MERGE объединяет delete/update/insert в одну атомарную команду без
--     отдельных INSERT/UPDATE/DELETE и без гонки между проверкой и изменением.
--   • Порядок WHEN MATCHED важен: удаление проверяется раньше общего UPDATE,
--     иначе строка с sync_action='delete' была бы обновлена, а не удалена.
--   • EXISTS/UPDATE не нужен: PostgreSQL 15+ MERGE читает source один раз.
--   • product_id существующей строки берётся из target и не перезаписывается.
--     Для новых строк явный product_id приходит из staging — это делает
--     состояние детерминированным при повторных запусках в разных
--     транзакциях (sequence не откатывается).
--   • В PostgreSQL 16 MERGE не поддерживает RETURNING. Поэтому проверка
--     состояния делается отдельным SELECT в той же транзакции; это позволяет
--     увидеть и удаления, и вставки, которые не отражаются в update count.
--   • На больших объёмах MERGE требует уникального индекса по sku
--     (он есть) и может блокировать затронутые строки; батчи и ретраи
--     проектируются под требования SLA.
-- =============================================================================

MERGE INTO products AS p
USING product_sync_staging AS s
ON p.sku = s.sku
WHEN MATCHED AND s.sync_action = 'delete' THEN
    DELETE
WHEN MATCHED THEN
    UPDATE SET
        name = s.name,
        category_id = s.category_id,
        price = s.price,
        cost = s.cost,
        stock = s.stock,
        rating = s.rating,
        tags = s.tags,
        attributes = s.attributes,
        is_active = s.is_active,
        created_at = s.created_at
WHEN NOT MATCHED THEN
    INSERT (
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
    VALUES (
        s.product_id,
        s.sku,
        s.name,
        s.category_id,
        s.price,
        s.cost,
        s.stock,
        s.rating,
        s.tags,
        s.attributes,
        s.is_active,
        s.created_at
    );
