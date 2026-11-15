-- =============================================================================
-- KATA 062 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • Начальный баланс равен 0. SUM(amount) с фреймом от начала раздела до
--     текущей строки даёт баланс после каждой транзакции.
--   • Порядок occurred_at + transaction_id стабилен даже при двух операциях
--     в одну секунду. Без tie-breaker выбор «первой» был бы недетерминирован.
--   • row_number по отрицательным строкам позволяет взять именно первый
--     выход в минус на пользователя.
--   • ROWS, а не RANGE: нам нужен накопительный итог по строкам транзакций.
--     RANGE с одинаковым временем включил бы все операции этого момента и
--     мог показать баланс после них, а не после конкретной транзакции.
--   • Индекс account_transactions(user_id, occurred_at, transaction_id)
--     поддерживает порядок чтения.
-- =============================================================================

WITH ledger AS (
    SELECT
        t.transaction_id,
        t.user_id,
        t.occurred_at,
        t.amount,
        sum(t.amount) OVER (
            PARTITION BY t.user_id
            ORDER BY t.occurred_at, t.transaction_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_balance
    FROM account_transactions t
),
first_negative AS (
    SELECT
        *,
        row_number() OVER (
            PARTITION BY user_id
            ORDER BY occurred_at, transaction_id
        ) AS negative_order
    FROM ledger
    WHERE running_balance < 0
)
SELECT
    f.user_id,
    u.full_name,
    f.transaction_id,
    f.occurred_at,
    f.amount,
    f.running_balance
FROM first_negative f
JOIN users u ON u.user_id = f.user_id
WHERE f.negative_order = 1
ORDER BY f.user_id ASC;
