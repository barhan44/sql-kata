-- =============================================================================
-- KATA 081 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • GROUPING SETS вычисляет четыре независимых уровня агрегации за один
--     проход по соединённым данным. UNION ALL из четырёх запросов читал бы
--     исходные таблицы несколько раз и дублировал код.
--   • GROUPING(column) = 1 означает, что колонка была свёрнута в текущем
--     наборе. Это надёжнее COALESCE: настоящий NULL в данных не спутать с
--     итоговой строкой.
--   • COUNT(DISTINCT order_id) корректен, потому что один заказ может
--     содержать несколько позиций категории/региона.
--   • Region — страна клиента (users.country), а не адрес доставки; отчёт
--     строится по billing-профилю.
--   • Для больших хранилищ подобные сводки часто материализуют; на OLTP-схеме
--     важны индексы orders(status), order_items(order_id) и products(category_id).
-- =============================================================================

SELECT
    CASE
        WHEN GROUPING(u.country) = 1 THEN 'ALL'
        ELSE u.country::text
    END AS region,
    CASE
        WHEN GROUPING(c.name) = 1 THEN 'ALL'
        ELSE c.name
    END AS category_name,
    count(DISTINCT o.order_id) AS orders_count,
    sum(oi.line_total) AS revenue,
    GROUPING(u.country) = 1 AS is_region_total,
    GROUPING(c.name) = 1 AS is_category_total
FROM orders o
JOIN users u ON u.user_id = o.user_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status = 'delivered'
GROUP BY GROUPING SETS (
    (u.country, c.name),
    (u.country),
    (c.name),
    ()
)
ORDER BY is_region_total ASC,
         is_category_total ASC,
         region ASC,
         category_name ASC;
