-- =============================================================================
-- KATA 055 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • user_metrics агрегирует только delivered-заказы; клиенты без покупок
--     не участвуют в RFM.
--   • Recency считается от фиксированной контрольной даты 2024-07-01,
--     поэтому отчёт не зависит от текущего времени.
--   • ROW-функции NTILE делят клиентов на четыре группы. Для recency
--     инвертируем номер: «5 - quartile» даёт 4 самым свежим клиентам.
--     Для frequency/monetary более высокий скор соответствует большим
--     значениям, поэтому NTILE идёт по возрастанию.
--   • user_id в ORDER BY каждого NTILE — tie-breaker. Без него границы
--     одинаковых значений были бы недетерминированными.
--   • CASE применяется после вычисления скоров. Порядок WHEN задаёт
--     приоритет сегментов: vip проверяется первым.
--   • Финальный GROUP BY сворачивает клиентов в сегменты и считает средние.
--     ROUND фиксирует точность отчёта.
--   • На больших данных для RFM часто материализуют агрегаты по пользователю
--     или считают их в отдельное окно, чтобы не пересчитывать историю заказов
--     при каждом запросе.
-- =============================================================================

WITH user_metrics AS (
    SELECT
        o.user_id,
        max(o.created_at)::date AS last_order_date,
        count(*) AS frequency,
        sum(o.total_amount) AS monetary
    FROM orders o
    WHERE o.status = 'delivered'
    GROUP BY o.user_id
),
scored AS (
    SELECT
        user_id,
        DATE '2024-07-01' - last_order_date AS recency_days,
        frequency,
        monetary,
        5 - ntile(4) OVER (
            ORDER BY last_order_date DESC, user_id ASC
        ) AS r_score,
        ntile(4) OVER (
            ORDER BY frequency ASC, user_id ASC
        ) AS f_score,
        ntile(4) OVER (
            ORDER BY monetary ASC, user_id ASC
        ) AS m_score
    FROM user_metrics
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN r_score = 4 AND m_score = 4 THEN 'vip'
            WHEN r_score >= 3 AND f_score >= 2 THEN 'loyal'
            WHEN r_score <= 2 AND m_score >= 3 THEN 'at_risk'
            ELSE 'regular'
        END AS segment
    FROM scored
)
SELECT
    segment,
    count(*) AS customers,
    round(avg(recency_days), 1) AS avg_recency_days,
    round(avg(frequency), 2) AS avg_frequency,
    round(avg(monetary), 2) AS avg_monetary,
    round(sum(monetary), 2) AS total_revenue
FROM segmented
GROUP BY segment
ORDER BY total_revenue DESC, segment ASC;
