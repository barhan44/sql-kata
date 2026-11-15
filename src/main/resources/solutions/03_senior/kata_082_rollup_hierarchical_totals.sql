-- =============================================================================
-- KATA 082 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • ROLLUP(year, quarter, month) последовательно убирает измерения справа
--     налево: (year,quarter,month) → (year,quarter) → (year) → ().
--     Это ровно иерархические итоги месяц → квартал → год → всё.
--   • period_label строится по GROUPING(), а не по значению NULL: так пустые
--     данные не перепутаются со строкой-итогом.
--   • year/quarter/month остаются NULL в итоговых строках — это стандартное
--     представление ROLLUP. Клиент может использовать label для отображения.
--   • Сортировка по GROUPING() выносит детали и итоги в предсказуемом порядке,
--     не полагаясь на порядок выдачи агрегатора.
--   • На больших данных ROLLUP эффективнее нескольких GROUP BY + UNION ALL,
--     но требует памяти под агрегаты; при необходимости используют
--     MATERIALIZED VIEW для готовых сводок.
-- =============================================================================

WITH order_periods AS (
    SELECT
        extract(year FROM created_at)::integer AS year,
        extract(quarter FROM created_at)::integer AS quarter,
        extract(month FROM created_at)::integer AS month,
        total_amount
    FROM orders
    WHERE status = 'delivered'
)
SELECT
    year,
    quarter,
    month,
    CASE
        WHEN GROUPING(year) = 1 THEN 'ИТОГО ВСЁ'
        WHEN GROUPING(quarter) = 1 THEN 'ИТОГО ЗА ГОД'
        WHEN GROUPING(month) = 1 THEN 'ИТОГО ЗА КВАРТАЛ'
        ELSE format('%s-%s', year, lpad(month::text, 2, '0'))
    END AS period_label,
    count(*) AS orders_count,
    sum(total_amount) AS revenue
FROM order_periods
GROUP BY ROLLUP (year, quarter, month)
ORDER BY GROUPING(year) ASC,
         GROUPING(quarter) ASC,
         GROUPING(month) ASC,
         year ASC,
         quarter ASC,
         month ASC;
