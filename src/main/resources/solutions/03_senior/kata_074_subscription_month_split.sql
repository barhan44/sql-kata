-- =============================================================================
-- KATA 074 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Anchor создаёт по одной строке на подписку с месяцем начала.
--   • Рекурсия увеличивает period_month на месяц, пока он не достиг месяца
--     end_date. Каждая ветка останавливается самостоятельно.
--   • active_days — пересечение [start_date, end_date] с календарным месяцем,
--     границы включительно, поэтому используется + 1.
--   • daily_rate — total_amount, делённая на полное число дней подписки.
--     NULLIF защищает от невозможного нулевого периода.
--   • allocated_amount округляется до копеек. Из-за округления сумма по
--     месяцам может отличаться от total_amount на несколько копеек; для
--     финансового учёта остаток обычно относят в последний месяц отдельно.
--   • numeric сохраняет точность денег, смена месяца через INTERVAL работает
--     независимо от длины месяца.
-- =============================================================================

WITH RECURSIVE expanded AS (
    SELECT
        s.subscription_id,
        s.user_id,
        s.plan,
        s.start_date,
        s.end_date,
        s.total_amount,
        date_trunc('month', s.start_date)::date AS period_month
    FROM user_subscriptions s

    UNION ALL

    SELECT
        e.subscription_id,
        e.user_id,
        e.plan,
        e.start_date,
        e.end_date,
        e.total_amount,
        (e.period_month + INTERVAL '1 month')::date
    FROM expanded e
    WHERE e.period_month < date_trunc('month', e.end_date)::date
),
prorated AS (
    SELECT
        *,
        LEAST(
            end_date,
            (period_month + INTERVAL '1 month - 1 day')::date
        ) - GREATEST(start_date, period_month) + 1 AS active_days,
        total_amount / NULLIF(end_date - start_date + 1, 0) AS daily_rate
    FROM expanded
)
SELECT
    subscription_id,
    user_id,
    plan,
    period_month,
    active_days,
    round(daily_rate * active_days, 2) AS allocated_amount
FROM prorated
ORDER BY subscription_id ASC, period_month ASC;
