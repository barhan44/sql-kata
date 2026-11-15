-- =============================================================================
-- KATA 063 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • attempts содержит все платёжные попытки, а не только успешные:
--     неудача должна разрывать серию.
--   • failure_group — накопительная сумма неуспешных попыток. Внутри одной
--     группы все captured-попытки идут подряд, поэтому GROUP BY даёт серии.
--   • failed, authorized и refunded прорывают серию: financial success —
--     только captured.
--   • row_number по длине серии выбирает лучшую; при равенстве — самую раннюю.
--   • LAG не нужен: gaps-and-islands через группирующий счётчик устойчивее
--     к нескольким неудачам подряд.
--   • Индексы payments(order_id), orders(user_id) и payments(paid_at)
--     ускоряют сборку попыток по клиенту.
-- =============================================================================

WITH attempts AS (
    SELECT
        o.user_id,
        p.payment_id,
        p.paid_at,
        CASE WHEN p.status = 'captured' THEN 1 ELSE 0 END AS is_captured,
        CASE WHEN p.status <> 'captured' THEN 1 ELSE 0 END AS is_failure
    FROM payments p
    JOIN orders o ON o.order_id = p.order_id
),
grouped AS (
    SELECT
        *,
        sum(is_failure) OVER (
            PARTITION BY user_id
            ORDER BY paid_at, payment_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS failure_group
    FROM attempts
),
streaks AS (
    SELECT
        user_id,
        failure_group,
        count(*) AS streak_length,
        min(paid_at) AS streak_started_at,
        max(paid_at) AS streak_ended_at
    FROM grouped
    WHERE is_captured = 1
    GROUP BY user_id, failure_group
),
ranked AS (
    SELECT
        *,
        row_number() OVER (
            PARTITION BY user_id
            ORDER BY streak_length DESC, streak_started_at ASC, failure_group ASC
        ) AS streak_rank
    FROM streaks
)
SELECT
    r.user_id,
    u.full_name,
    r.streak_length AS longest_streak,
    r.streak_started_at,
    r.streak_ended_at
FROM ranked r
JOIN users u ON u.user_id = r.user_id
WHERE r.streak_rank = 1
ORDER BY r.user_id ASC;
