-- =============================================================================
-- KATA 015 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Один проход GROUP BY с условными агрегатами дешевле, чем четыре
--     отдельных запроса или JOIN нескольких агрегатов по месяцу.
--   • CASE WHEN ... THEN 1 ELSE 0 END внутри SUM даёт bigint. Использование
--     COUNT(CASE WHEN ... THEN 1 END) тоже корректно, но SUM с ELSE 0 явно
--     показывает, что в счётчике всегда есть число.
--   • date_trunc('month', timestamptz) возвращает timestamptz; ::date
--     фиксирует тип итоговой колонки date и убирает время.
--   • Тип month = date. GROUP BY 1 ссылается на выходное выражение.
--   • Индекс (status, created_at) полезен для фильтров по статусу в других
--     отчётах; этот запрос читает всю таблицу, поэтому сортировка групп
--     ожидаема.
-- =============================================================================

SELECT
    date_trunc('month', created_at)::date AS month,
    count(*) AS total_orders,
    sum(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    sum(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    sum(CASE WHEN status = 'returned' THEN 1 ELSE 0 END) AS returned_orders
FROM orders
GROUP BY 1
ORDER BY month ASC;
