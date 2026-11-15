-- =============================================================================
-- KATA 099 · Эталонное решение
-- =============================================================================
-- EXPLAIN (ANALYZE): Append из двух Bitmap Heap Scan:
--   1) events_big_user_status_idx       (user_id = 7 AND status='PAID')
--   2) events_big_merchant_status_created_idx
--      (merchant_id = 7 AND status='PAID'), затем Filter user_id <> 7
--   -> Sort by event_id. Seq Scan по events_big отсутствует.
--
-- Почему так:
--   • Каждая ветка UNION ALL — отдельный индексный доступ по своему набору
--     колонок. Планировщику не нужно строить общий OR-предикат и выбирать
--     между BitmapOr и Seq Scan.
--   • Явное условие user_id <> 7 во второй ветке удаляет строки, уже
--     выбранные первой веткой. Это дешевле, чем UNION (который добавил бы
--     сортировку/хеширование для дедупликации всего результата).
--   • UNION ALL сохраняет дубликаты только в том случае, если их не убрать
--     вручную. Здесь логика разбиения множеств гарантирует отсутствие
--     пересечения: первая ветка — user_id=7, вторая — merchant_id=7 и
--     user_id<>7.
--   • Если бы строки были широкими, а результат большим, можно было бы
--     рассмотреть UNION с сортировкой или EXISTS-семиджойн; на нашем объёме
--     UNION ALL + Filter — самый предсказуемый вариант.
--   • Оба составных индекса начинаются с колонки равенства, что соответствует
--     правилу Equality first.
-- =============================================================================

SELECT
    e.event_id,
    e.user_id,
    e.merchant_id,
    e.status,
    e.amount
FROM events_big e
WHERE e.user_id = 7
  AND e.status = 'PAID'

UNION ALL

SELECT
    e.event_id,
    e.user_id,
    e.merchant_id,
    e.status,
    e.amount
FROM events_big e
WHERE e.merchant_id = 7
  AND e.status = 'PAID'
  AND e.user_id <> 7
ORDER BY event_id ASC;
