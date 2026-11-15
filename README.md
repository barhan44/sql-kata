# SQL Kata

Практический тренажёр по **PostgreSQL 16+** на Java 21, Maven и Testcontainers.
Задачи идут по уровням: **Junior → Middle → Senior → Pro/Tuning**. В репозитории
уже доступны три уровня — 90 кат: Junior (001–025), Middle (026–055) и
Senior (056–090).

Проверка не имитирует SQL парсером: настоящий PostgreSQL в Docker выполняет
запрос ученика и эталонный запрос, после чего сравнивает имена колонок, SQL-типы,
значения и порядок строк. Обе транзакции откатываются, поэтому база остаётся
неизменной между тестами.

## Быстрый старт

Требования:

- JDK 21+
- Maven 3.9+
- Docker с запущенным daemon (Docker Desktop, Colima, OrbStack и т. п.)

```bash
# 1. Убедиться, что инфраструктура и все 90 эталонов работают
mvn test -DuseSolution=true

# 2. Запустить только одну кату
mvn test -Dtest=Kata001_ActiveRuCustomersTest

# 3. Запустить Middle-каты
mvn test -Dtest='Kata02*,Kata03*,Kata04*,Kata05*' -DuseSolution=true

# 4. Запустить Senior-каты
mvn test -Dtest='Kata056*,Kata057*,Kata058*,Kata059*,Kata06*,Kata07*,Kata08*,Kata090*' -DuseSolution=true

# 5. Обычный режим: заглушки должны падать с diff-сообщением
mvn test
```

В режиме `-DuseSolution=true` в качестве кандидата используется файл из
`solutions/...`. Это быстрый способ проверить целостность всего набора после
изменения схемы, данных или движка проверки.

При обычном `mvn test` все 90 заглушек `SELECT 1 WHERE FALSE;` ожидаемо падают.
Это и есть стартовое состояние тренажёра.

## Как решать кату

1. Откройте условие:
   `src/main/resources/katas/01_junior/kata_001_active_ru_customers.sql`.
2. Напишите запрос вместо `SELECT 1 WHERE FALSE;`. Условие, порядок колонок,
   их типы и сортировка перечислены в SQL-комментарии.
3. Запустите соответствующий тест:
   ```bash
   mvn test -Dtest=Kata001_ActiveRuCustomersTest
   ```
4. Если результат не совпал, тест покажет причину: несовпадение колонок,
   типа, количества строк или конкретной ячейки, а также первые строки
   эталона и кандидата.
5. Эталонное решение с разбором лежит рядом:
   `src/main/resources/solutions/01_junior/kata_001_active_ru_customers.sql`.
   Сверяться с ним лучше после собственной попытки.

## Как работает проверка

`SqlKataVerifier`:

1. Читает SQL ученика из `katas/...` и SQL эталона из `solutions/...`.
   При `-DuseSolution=true` учеником считается эталон.
2. Открывает отдельное соединение и транзакцию для кандидата, выполняет запрос,
   читает весь `ResultSet` и делает `ROLLBACK`.
3. Повторяет шаг 2 для эталона в другой транзакции.
4. Сравнивает:
   - количество и имена колонок;
   - SQL-типы колонок (псевдонимы `serial`/`bigserial` приводятся к базовым
     `int4`/`int8`);
   - количество строк;
   - значения с учётом `NULL`, массивов, JSONB и `BigDecimal`;
   - порядок строк — **он обязателен**, поэтому в каждой кате есть `ORDER BY`.
5. При расхождении выбрасывает `AssertionError` с подробным diff-выводом.

Запрос выполняется в транзакции с откатом. Это позволяет проверять задачи
на `UPDATE`, `DELETE`, `INSERT ... RETURNING` без загрязнения базы — в Middle
такие каты уже есть (052–054). Один файл каты должен содержать **одну
SQL-команду** (допускается завершающая точка с запятой и комментарии).

Для DML без `RETURNING` (в PostgreSQL 16 это `MERGE`) используется
`assertKataStateMatches(kataPath, verificationPath)`: после DML в той же
транзакции выполняется проверочный SELECT, сравниваются снимки состояния
кандидата и эталона, затем выполняется `ROLLBACK`. Так проверяется kata_084,
не ослабляя основной движок сравнения.

### Контейнер

Базовый класс `AbstractSqlKataTest` содержит единственный статический
`PostgreSQLContainer<>("postgres:16-alpine")`. Maven Surefire настроен на
`forkCount=1` и `reuseForks=true`, поэтому контейнер и схема поднимаются один раз
на весь прогон. Если увеличить число форков, каждый JVM получит свой контейнер.

Используется Testcontainers `2.0.5`: Docker Engine 29+ требует API не ниже 1.40,
тогда как docker-java из ветки 1.x по умолчанию обращается к устаревшему API.
В Testcontainers 2.x модули называются `testcontainers-postgresql` и
`testcontainers-junit-jupiter`.

## Схема и данные

Схема загружается при старте контейнера в три шага:

1. `src/main/resources/schema/01_init_schema.sql` — базовая схема и данные.
2. `src/main/resources/schema/02_middle_seed.sql` — аддитивные Middle-данные:
   сотрудники с равными зарплатами, captured-платёж для зависшего заказа,
   аудит-события с вложенным JSONB и JSON-массивами, таблица контактов.
3. `src/main/resources/schema/03_senior_seed.sql` — поток событий, счета с
   пропусками, интервалы подписок, транзакции, граф зависимостей с циклом,
   staging-дерево, JSONB-корзины и staging для `MERGE`.

Базовые строки не изменяются — seed-скрипты только добавляют новые данные.

| Таблица | Строк | Назначение |
|---|---:|---|
| `departments` | 20 | отделы и бюджеты |
| `employees` | 23 | иерархия сотрудников и равные зарплаты для ranking |
| `users` | 25 | клиенты, статусы, тарифы, JSONB-настройки, теги |
| `categories` | 20 | дерево категорий через `parent_id` |
| `products` | 28 | каталог, цены, остатки, JSONB-атрибуты |
| `orders` | 30 | заказы за январь–июнь 2024 |
| `order_items` | 44 | позиции с вычисляемым `line_total` |
| `payments` | 34 | оплаты, неуспешные попытки, возвраты и «зависший» платёж |
| `user_sessions` | 41 | сессии, устройства, конверсии и пересекающиеся интервалы |
| `audit_logs` | 39 | журнал событий с дубликатами, JSONB и логином без заказа |
| `user_contact_candidates` | 20 | несколько контактов пользователя из разных источников |
| `user_events` | 38 | поток логинов, просмотров, поиска и покупок |
| `invoices` | 20 | счета с пропусками в нумерации |
| `user_subscriptions` | 20 | пересекающиеся периоды подписок |
| `account_transactions` | 30 | транзакции для накопительного баланса |
| `task_nodes` | 16 | вершины графа задач |
| `task_dependencies` | 22 | рёбра DAG и циклическая компонента |
| `category_tree_staging` | 12 | staging-дерево с сиротами и превышением глубины |
| `shopping_carts` | 20 | JSONB-корзины с вложенными items/payment/debug |
| `product_sync_staging` | 6 | staging для синхронизации каталога через `MERGE` |

В данных намеренно встречаются:

- пользователи без заказов;
- товары без продаж;
- `NULL` в телефоне, рейтинге, остатке и уровне лояльности;
- отделы без сотрудников и сотрудник без отдела;
- отменённые заказы, возвраты и отрицательные refund-платежи;
- pending-заказ с успешно списанным платежом;
- повторные события, аудит-события в пределах минуты и несколько сессий в день;
- сотрудники с равной зарплатой внутри отдела;
- JSONB-массивы тегов, нативные массивы и конфликтующие контакты;
- ежедневные серии логинов, 30-минутные паузы и пересекающиеся сессии;
- пропуски в нумерации счетов и пересекающиеся подписки;
- цикл в графе задач, staging-сироты и превышение глубины дерева;
- иерархии категорий и сотрудников.

## Каталог Junior-уровня

| № | Тема | Файл |
|---|---|---|
| 001 | Фильтрация, `WHERE`, `IN`, `ORDER BY` | `active_ru_customers` |
| 002 | `IS DISTINCT FROM`, `COALESCE` | `null_safe_loyalty` |
| 003 | `ORDER BY ... NULLS LAST` | `nulls_last_catalog` |
| 004 | Строковые функции | `email_profile_strings` |
| 005 | Числовые функции и округление | `product_margins` |
| 006 | `INNER JOIN` двух таблиц | `orders_with_customers` |
| 007 | `INNER JOIN` трёх таблиц | `delivered_order_lines` |
| 008 | `LEFT JOIN` / anti-join | `users_without_orders` |
| 009 | Anti-join и `NULL` в FK | `products_without_sales` |
| 010 | `SELF JOIN` | `employee_manager` |
| 011 | `FULL OUTER JOIN` | `department_staffing` |
| 012 | `LEFT JOIN` с условием в `ON` | `orders_optional_payment` |
| 013 | `GROUP BY`, `COUNT(DISTINCT)` | `category_sales` |
| 014 | `HAVING` | `loyal_customers_having` |
| 015 | Условная агрегация `CASE WHEN` | `monthly_order_funnel` |
| 016 | Конверсия, `NULLIF` | `session_conversion_by_device` |
| 017 | `LEFT JOIN` + агрегаты | `loyalty_tier_performance` |
| 018 | Доля возвратов | `product_returns` |
| 019 | Pivot через `CASE WHEN` | `daily_session_activity` |
| 020 | Скалярный подзапрос | `above_average_orders` |
| 021 | Подзапрос в `FROM` | `customer_average_check` |
| 022 | Коррелированный `EXISTS` | `products_with_delivered_sales` |
| 023 | `NOT EXISTS` vs ловушка `NOT IN` | `users_without_converted_session` |
| 024 | `UNION` vs `UNION ALL` | `unique_email_domains` |
| 025 | `DATE_TRUNC`, `INTERVAL` | `first_order_window` |

Пути: `katas/01_junior/` и `solutions/01_junior/`. Тесты —
`src/test/java/dev/sqlkata/junior/`.

## Прогресс Middle-уровня (026–055)

| Блок | Каты | Темы | Статус |
|---|---|---|---|
| 1 | 026–035 | оконные функции, `ROW_NUMBER`/`RANK`/`DENSE_RANK`, `LAG`/`LEAD`, running total, `NTILE` | ✅ 10/10 |
| 2 | 036–045 | `DISTINCT ON`, `FILTER`, CTE-воронка, `EXCEPT`, retention, дубликаты, перцентили, приоритеты | ✅ 10/10 |
| 3 | 046–055 | JSONB, `jsonb_array_elements`, JSON-отчёт, массивы, `generate_series`, UPSERT/UPDATE/DELETE с `RETURNING`, RFM | ✅ 10/10 |
| **Итого** | **026–055** | **Middle** | **✅ 30/30** |

## Каталог Middle-уровня

| № | Тема | Файл |
|---|---|---|
| 026 | `ROW_NUMBER`, первый/последний заказ | `order_numbering` |
| 027 | `ROW_NUMBER` vs `RANK` vs `DENSE_RANK` | `salary_rank_comparison` |
| 028 | Top-N per group через `DENSE_RANK` | `top3_per_category` |
| 029 | `LAG`: предыдущий заказ, разница суммы и времени | `order_lag_comparison` |
| 030 | `LEAD`: следующая сессия и длительность | `session_lead_forecast` |
| 031 | Running total денежного потока | `running_total_revenue` |
| 032 | Доли товара в категории и магазине | `revenue_share` |
| 033 | `NTILE(4)`: квартили LTV и VIP | `customer_ltv_quartiles` |
| 034 | `AVG`/`MAX`/`FIRST_VALUE` без `GROUP BY` | `salary_vs_department` |
| 035 | Аномальные скачки трат по окну предыдущих заказов | `spending_anomalies` |
| 036 | `DISTINCT ON` vs `ROW_NUMBER` | `latest_payment_distinct_on` |
| 037 | Pivot статусов через `FILTER` | `order_status_pivot` |
| 038 | Многошаговая CTE-воронка конверсии | `conversion_funnel` |
| 039 | `EXCEPT`: купили A, но не B | `category_except` |
| 040 | Когортный retention | `cohort_retention` |
| 041 | Дубликаты аудита в пределах минуты | `duplicate_events` |
| 042 | Квартальный pivot выручки | `quarterly_revenue_pivot` |
| 043 | Зависшие pending-заказы с captured-платежом | `stuck_pending_orders` |
| 044 | Медиана и P95 через `PERCENTILE_CONT` | `order_value_percentiles` |
| 045 | Приоритет источников контакта через `CASE` | `contact_priority` |
| 046 | Вложенный JSONB и безопасный `CAST` | `jsonb_nested_extract` |
| 047 | JSONB containment `@>` и GIN | `jsonb_containment` |
| 048 | `jsonb_array_elements_text` и статистика тегов | `jsonb_array_unnest` |
| 049 | JSON-отчёт через `jsonb_build_object`/`jsonb_agg` | `jsonb_report` |
| 050 | Нативные массивы: `&&`, `ANY`, `array_agg` | `native_arrays` |
| 051 | `generate_series` и дни без продаж | `calendar_gaps` |
| 052 | UPSERT `ON CONFLICT DO UPDATE` + `RETURNING *` | `product_upsert` |
| 053 | Массовый `UPDATE ... FROM` | `bulk_loyalty_update` |
| 054 | `DELETE ... USING` со stale-сессиями | `purge_stale_sessions` |
| 055 | RFM-сегментация через CTE и `NTILE` | `rfm_segmentation` |

Пути: `katas/02_middle/` и `solutions/02_middle/`. Тесты —
`src/test/java/dev/sqlkata/middle/`.

## Прогресс Senior-уровня (056–090)

| Блок | Каты | Темы | Статус |
|---|---|---|---|
| 1 | 056–067 | `RANGE`/`ROWS`, gaps & islands, sessionization, интервалы, rolling DAU, concurrency, MoM, именованные окна | ✅ 12/12 |
| 2 | 068–078 | рекурсивные CTE, деревья, графы, циклы, BFS, разворачивание периодов, кредитный график, DFS | ✅ 11/11 |
| 3 | 079–090 | `LATERAL`, `GROUPING SETS`/`ROLLUP`/`CUBE`, `MERGE`, SQL/JSON Path, JSONB-трансформация, IQR, keyset pagination, retention/LTV | ✅ 12/12 |
| **Итого** | **056–090** | **Senior** | **✅ 35/35** |

## Каталог Senior-уровня

| № | Тема | Файл |
|---|---|---|
| 056 | 7-дневное среднее через `RANGE` | `rolling_7d_average` |
| 057 | Скользящий максимум и `LAST_VALUE` | `sliding_max_last_value` |
| 058 | Gaps & Islands: серии логинов | `login_streaks` |
| 059 | Sessionization по 30-минутному таймауту | `event_sessionization` |
| 060 | Пропуски в нумерации счетов | `invoice_number_gaps` |
| 061 | Слияние пересекающихся интервалов | `merge_intervals` |
| 062 | Первый овердрафт баланса | `overdraft_detection` |
| 063 | Самая длинная серия успешных платежей | `payment_winning_streak` |
| 064 | Rolling 7-day DAU | `rolling_7d_dau` |
| 065 | Пик одновременных сессий | `concurrency_peak` |
| 066 | MoM growth с пустыми месяцами | `mom_growth` |
| 067 | Четыре метрики на именованных окнах | `named_windows_metrics` |
| 068 | Пути от корня к листьям категорий | `category_leaf_paths` |
| 069 | Восходящий обход категорий | `category_ancestors` |
| 070 | Выручка поддеревьев категорий | `subtree_revenue` |
| 071 | Организационная иерархия и payroll | `org_subtree_payroll` |
| 072 | Циклы в графе зависимостей | `dependency_cycles` |
| 073 | Кратчайший путь BFS | `shortest_dependency_path` |
| 074 | Разбиение подписок по месяцам | `subscription_month_split` |
| 075 | Рекурсивный график кредита | `recursive_loan_schedule` |
| 076 | Корневые предки и листья графа | `dependency_roots_leaves` |
| 077 | Валидация целостности дерева | `tree_integrity` |
| 078 | DFS pre-order категорий | `category_dfs_order` |
| 079 | Top-2 через `CROSS JOIN LATERAL` | `lateral_top2` |
| 080 | Первый заказ после события | `lateral_order_after_event` |
| 081 | `GROUPING SETS` по региону и категории | `grouping_sets_revenue` |
| 082 | Иерархические итоги через `ROLLUP` | `rollup_hierarchical_totals` |
| 083 | `CUBE` по каналу и статусу | `cube_channel_status` |
| 084 | Синхронизация каталога через `MERGE` | `merge_product_sync` |
| 085 | SQL/JSON Path по корзинам | `json_path_carts` |
| 086 | JSONB-агрегация и очистка документа | `jsonb_transform_carts` |
| 087 | Market Basket Analysis | `market_basket` |
| 088 | IQR-выбросы позиций | `iqr_outliers` |
| 089 | Keyset Pagination | `keyset_pagination` |
| 090 | Retention и LTV-прогноз | `retention_ltv_forecast` |

Пути: `katas/03_senior/` и `solutions/03_senior/`. Тесты —
`src/test/java/dev/sqlkata/senior/`. Проверочный SELECT для kata_084 лежит в
`verifications/03_senior/`.

## Дорожная карта

| Уровень | Каты | Темы | Статус |
|---|---|---|---|
| `01_junior` | 001–025 | фильтрация, NULL, JOIN, агрегаты, подзапросы, даты | ✅ готово |
| `02_middle` | 026–055 | окна, CTE, JSONB, массивы, `LATERAL`, DML с `RETURNING` | ✅ готово |
| `03_senior` | 056–090 | продвинутые фреймы, рекурсия и графы, `MERGE`, многомерная агрегация, SQL/JSON | ✅ готово |
| `04_pro_tuning` | 091–105 | планы, индексы, статистика, `EXPLAIN ANALYZE`, партиционирование | ⏳ запланировано |

Правила добавления следующих волн описаны в [CLAUDE.md](CLAUDE.md).

## Полезные команды

```bash
# Все эталоны
mvn test -DuseSolution=true

# Один тест в режиме эталона
mvn test -DuseSolution=true -Dtest=Kata090_RetentionLtvForecastTest

# Один тест с решением ученика
mvn test -Dtest=Kata090_RetentionLtvForecastTest

# Полный diff каты
cat target/surefire-reports/dev.sqlkata.senior.Kata084_MergeProductSyncTest.txt
```

## Требования к запросу

- Только PostgreSQL 16+; диалект других СУБД не поддерживается.
- Итоговые имена и порядок колонок — строго по условию.
- Выражениям нужны явные `AS`-псевдонимы.
- Сортировка только по заданным правилам, включая tie-breaker.
- Нельзя полагаться на случайный порядок строк.
- `LIMIT` применяется только если он указан в условии.
- Сравниваются и типы: при необходимости используйте явный `CAST`.
- Запрещены `COMMIT`, `ROLLBACK`, DDL и команды управления сессией внутри каты.
- Для задач на изменение данных вердикт выносится по `RETURNING`/счётчику
  изменённых строк; откат транзакции гарантирован.
- В DML-катах с `INSERT` identity-значения лучше задавать явно: PostgreSQL-
  последовательности не откатываются, поэтому auto-generated id у кандидата
  и эталона различались бы. Это показано в kata_052.
- `MERGE` в PostgreSQL 16 не поддерживает `RETURNING`; его результат
  проверяется отдельным SELECT-снимком состояния (kata_084).

Если Docker не запущен, тесты не смогут создать контейнер. Это единственная
внешняя зависимость тренажёра.
