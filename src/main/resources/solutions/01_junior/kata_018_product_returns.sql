-- =============================================================================
-- KATA 018 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • WHERE ограничивает только участвующие в расчёте статусы доставленных
--     и возвращённых заказов; отменённые и ожидающие не искажают знаменатель.
--   • Условная агрегация SUM(CASE WHEN ... THEN quantity ELSE 0 END)
--     считает возвращённые единицы в том же проходе, без второго запроса.
--   • HAVING оставляет товары с хотя бы одним возвратом. Его можно
--     сформулировать через тот же CASE-агрегат; это допустимо, поскольку
--     HAVING вычисляется после GROUP BY.
--   • NULLIF защищает деление, а 100.0 переводит расчёт в numeric.
--   • COUNT(DISTINCT order) здесь не нужен: считаем именно единицы товара.
-- =============================================================================

SELECT
    p.product_id,
    p.name AS product_name,
    sum(oi.quantity) AS shipped_units,
    sum(CASE WHEN o.status = 'returned' THEN oi.quantity ELSE 0 END) AS returned_units,
    round(
        100.0 * sum(CASE WHEN o.status = 'returned' THEN oi.quantity ELSE 0 END)
              / NULLIF(sum(oi.quantity), 0),
        2
    ) AS return_rate_pct
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status IN ('delivered', 'returned')
GROUP BY p.product_id, p.name
HAVING sum(CASE WHEN o.status = 'returned' THEN oi.quantity ELSE 0 END) > 0
ORDER BY return_rate_pct DESC, p.product_id ASC;
