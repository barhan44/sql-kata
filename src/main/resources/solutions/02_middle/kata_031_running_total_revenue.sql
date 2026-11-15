-- =============================================================================
-- KATA 031 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Сначала агрегируем платежи по дням: окно нельзя смешивать с GROUP BY
--     на одном уровне без CTE, а двухшаговый запрос проще читать.
--   • В финансовый поток включены captured и refunded. Refund-строки
--     отрицательные, поэтому daily_revenue может быть отрицательной,
--     а running_revenue — уменьшаться. Failed/authorized деньгами не являются.
--   • ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW задаёт накопительный
--     итог явно. Для уникальных дат RANGE дал бы тот же результат, но ROWS
--     устойчивее к возможным одинаковым значениям в ORDER BY.
--   • paid_at::date использует часовой пояс сессии. Для финансового отчёта
--     в продакшене зону нужно фиксировать явно; тестовые операции не
--     пересекают границу суток в UTC.
--   • Индекс payments(paid_at) помогает диапазонному чтению, если появится
--     фильтр по периоду.
-- =============================================================================

WITH daily AS (
    SELECT
        paid_at::date AS paid_on,
        sum(amount) AS daily_revenue
    FROM payments
    WHERE status IN ('captured', 'refunded')
    GROUP BY paid_at::date
)
SELECT
    paid_on,
    daily_revenue,
    sum(daily_revenue) OVER (
        ORDER BY paid_on
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM daily
ORDER BY paid_on ASC;
