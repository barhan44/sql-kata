-- =============================================================================
-- KATA 025 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • JOIN orders + GROUP BY находит первый заказ пользователя (MIN).
--   • Условие окна в HAVING использует min(o.created_at), потому что это
--     агрегат. BETWEEN включителен с обеих сторон: 30-й день входит.
--   • registered_at + INTERVAL '30 days' — понятная бизнес-граница; не нужно
--     вручную считать дни. DATE_TRUNC('month', registered_at) выделяет когорту
--     по месяцу, ::date стабилизирует тип.
--   • days_to_first_order — разность двух date, поэтому integer без времени.
--   • При большом объёме заказов запрос можно переписать через CTE с
--     предварительной агрегацией MIN по user_id; семантика останется той же.
--   • Пользователи без заказов не проходят INNER JOIN — это ожидаемо,
--     ведь первый заказ у них отсутствует.
-- =============================================================================

SELECT
    u.user_id,
    u.full_name,
    date_trunc('month', u.registered_at)::date AS cohort_month,
    min(o.created_at)::date AS first_order_date,
    min(o.created_at)::date - u.registered_at::date AS days_to_first_order
FROM users u
JOIN orders o ON o.user_id = u.user_id
GROUP BY u.user_id, u.full_name, u.registered_at
HAVING min(o.created_at) >= u.registered_at
   AND min(o.created_at) <= u.registered_at + INTERVAL '30 days'
ORDER BY days_to_first_order ASC, u.user_id ASC;
