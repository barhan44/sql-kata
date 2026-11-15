-- =============================================================================
-- KATA 088 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • PERCENTILE_CONT — ordered-set агрегат, который интерполирует значение
--     между соседними точками. Q1/Q3 считаются один раз по line_total всех
--     позиций и переносятся в каждую строку через CROSS JOIN.
--   • Для числового варианта PERCENTILE_CONT требуется double precision;
--     результат сразу приводим к numeric, чтобы дальше работать с деньгами
--     без бинарных сюрпризов.
--   • Фильтрация идёт по НЕокруглённым границам, округление — только для
--     вывода, иначе граница могла бы измениться.
--   • 1.5 — классический множитель Тьюки. Условия строгие.
--   • На больших данных такой запрос делает sort/aggregate по line_total;
--     при регулярном использовании лучше материализовывать границы или
--     считать их отдельным отчётом.
-- =============================================================================

WITH bounds AS (
    SELECT
        percentile_cont(0.25) WITHIN GROUP (
            ORDER BY oi.line_total::double precision
        )::numeric AS q1,
        percentile_cont(0.75) WITHIN GROUP (
            ORDER BY oi.line_total::double precision
        )::numeric AS q3
    FROM order_items oi
),
classified AS (
    SELECT
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        oi.line_total,
        b.q1,
        b.q3,
        b.q3 - b.q1 AS iqr,
        b.q1 - 1.5 * (b.q3 - b.q1) AS lower_bound,
        b.q3 + 1.5 * (b.q3 - b.q1) AS upper_bound,
        CASE
            WHEN oi.line_total < b.q1 - 1.5 * (b.q3 - b.q1) THEN 'low'
            WHEN oi.line_total > b.q3 + 1.5 * (b.q3 - b.q1) THEN 'high'
        END AS outlier_side
    FROM order_items oi
    CROSS JOIN bounds b
)
SELECT
    order_item_id,
    order_id,
    product_id,
    line_total,
    round(q1, 2) AS q1,
    round(q3, 2) AS q3,
    round(iqr, 2) AS iqr,
    round(lower_bound, 2) AS lower_bound,
    round(upper_bound, 2) AS upper_bound,
    outlier_side
FROM classified
WHERE outlier_side IS NOT NULL
ORDER BY line_total DESC, order_item_id ASC;
