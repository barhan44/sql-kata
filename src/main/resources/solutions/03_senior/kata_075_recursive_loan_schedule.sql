-- =============================================================================
-- KATA 075 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • params фиксирует все входные значения в одном месте, чтобы рекурсия
--     не повторяла магические числа.
--   • Anchor считает первый платёж. Рекурсивная часть берёт closing_balance
--     предыдущего месяца как opening_balance следующего.
--   • interest_amount считается на остаток до платежа, principal_amount
--     ограничен LEAST(20000, balance), чтобы последний платёж не ушёл ниже нуля.
--   • Условие остановки month_number < term AND closing_balance > 0 защищает
--     от лишних строк и потенциально бесконечной рекурсии.
--   • ROUND(...,2) применяется к проценту, денежные значения остаются numeric.
--   • Для аннуитетной схемы формула платежа была бы другой; здесь намеренно
--     используется равное погашение основного долга — это проще проверить
--     и наглядно показывает силу WITH RECURSIVE.
-- =============================================================================

WITH RECURSIVE params AS (
    SELECT
        120000.00::numeric AS principal,
        0.01::numeric AS monthly_rate,
        6 AS term,
        20000.00::numeric AS principal_payment,
        DATE '2024-01-01' AS first_payment_date
),
schedule AS (
    SELECT
        1 AS month_number,
        p.first_payment_date AS payment_date,
        p.principal AS opening_balance,
        round(p.principal * p.monthly_rate, 2) AS interest_amount,
        LEAST(p.principal_payment, p.principal) AS principal_amount,
        round(p.principal * p.monthly_rate, 2)
            + LEAST(p.principal_payment, p.principal) AS payment_amount,
        p.principal - LEAST(p.principal_payment, p.principal) AS closing_balance
    FROM params p

    UNION ALL

    SELECT
        s.month_number + 1,
        (s.payment_date + INTERVAL '1 month')::date,
        s.closing_balance,
        round(s.closing_balance * p.monthly_rate, 2),
        LEAST(p.principal_payment, s.closing_balance),
        round(s.closing_balance * p.monthly_rate, 2)
            + LEAST(p.principal_payment, s.closing_balance),
        s.closing_balance - LEAST(p.principal_payment, s.closing_balance)
    FROM schedule s
    CROSS JOIN params p
    WHERE s.month_number < p.term
      AND s.closing_balance > 0
)
SELECT
    month_number,
    payment_date,
    opening_balance,
    interest_amount,
    principal_amount,
    payment_amount,
    closing_balance
FROM schedule
ORDER BY month_number ASC;
