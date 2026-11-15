-- =============================================================================
-- KATA 060 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • LEAD смотрит на следующий существующий invoice_no, не создавая строк
--     для отсутствующих номеров.
--   • Если next - current > 1, между ними есть пропуск.
--     missing_from = current + 1, missing_to = next - 1.
--   • Условие не создаёт диапазон после последнего счёта: у последней строки
--     LEAD = NULL, и сравнение не проходит.
--   • Альтернативы — generate_series по всему диапазону и LEFT JOIN, но на
--     больших разреженных диапазонах это дороже. LEAD-подход читает только
--     существующие строки.
--   • Индекс PRIMARY KEY(invoice_no) позволяет получить строки сразу в нужном
--     порядке без сортировки.
-- =============================================================================

WITH invoice_neighbours AS (
    SELECT
        invoice_no,
        lead(invoice_no) OVER (ORDER BY invoice_no) AS next_invoice_no
    FROM invoices
)
SELECT
    invoice_no + 1 AS missing_from,
    next_invoice_no - 1 AS missing_to,
    next_invoice_no - invoice_no - 1 AS missing_count
FROM invoice_neighbours
WHERE next_invoice_no > invoice_no + 1
ORDER BY missing_from ASC;
