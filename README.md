# SQL Kata

Практический тренажёр по **PostgreSQL 16+** на Java 21, Maven и Testcontainers.
Задачи идут по уровням: **Junior → Middle → Senior → Pro/Tuning**. В репозитории
уже доступен первый уровень — 25 кат.

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
# 1. Убедиться, что инфраструктура и все 25 эталонов работают
mvn test -DuseSolution=true

# 2. Запустить только одну кату
mvn test -Dtest=Kata001_ActiveRuCustomersTest

# 3. Обычный режим: заглушки должны падать с diff-сообщением
mvn test
```

В режиме `-DuseSolution=true` в качестве кандидата используется файл из
`solutions/...`. Это быстрый способ проверить целостность всего набора после
изменения схемы, данных или движка проверки.

При обычном `mvn test` все 25 заглушек `SELECT 1 WHERE FALSE;` ожидаемо падают.
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

Запрос выполняется в транзакции с откатом. Это позволяет добавлять в будущем
задачи на `UPDATE`, `DELETE`, `INSERT ... RETURNING` без загрязнения базы.
Один файл каты должен содержать **одну SQL-команду** (допускается завершающая
точка с запятой и комментарии).

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

Единая схема — `src/main/resources/schema/01_init_schema.sql`. Она загружается
при старте контейнера.

| Таблица | Строк | Назначение |
|---|---:|---|
| `departments` | 20 | отделы и бюджеты |
| `employees` | 21 | иерархия сотрудников через `manager_id` |
| `users` | 25 | клиенты, статусы, тарифы, JSONB-настройки, теги |
| `categories` | 20 | дерево категорий через `parent_id` |
| `products` | 28 | каталог, цены, остатки, JSONB-атрибуты |
| `orders` | 30 | заказы за январь–июнь 2024 |
| `order_items` | 44 | позиции с вычисляемым `line_total` |
| `payments` | 33 | оплаты, неуспешные попытки и возвраты |
| `user_sessions` | 35 | сессии, устройства и конверсии |
| `audit_logs` | 32 | журнал событий с дубликатами и JSONB |

В данных намеренно встречаются:

- пользователи без заказов;
- товары без продаж;
- `NULL` в телефоне, рейтинге, остатке и уровне лояльности;
- отделы без сотрудников и сотрудник без отдела;
- отменённые заказы, возвраты и отрицательные refund-платежи;
- повторные события и несколько сессий в один день;
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

## Дорожная карта

| Уровень | Каты | Темы |
|---|---|---|
| `01_junior` | 001–025 | фильтрация, NULL, JOIN, агрегаты, подзапросы, даты |
| `02_middle` | 026–055 | оконные функции, CTE, JSONB, массивы, `LATERAL`, рекурсия |
| `03_senior` | 056–075 | сложная аналитика, транзакции, блокировки, `MERGE`, моделирование |
| `04_pro_tuning` | 076–090 | планы, индексы, статистика, `EXPLAIN ANALYZE`, партиционирование |

Правила добавления следующих волн описаны в [CLAUDE.md](CLAUDE.md).

## Полезные команды

```bash
# Все эталоны
mvn test -DuseSolution=true

# Один тест в режиме эталона
mvn test -DuseSolution=true -Dtest=Kata025_FirstOrderWindowTest

# Один тест с решением ученика
mvn test -Dtest=Kata025_FirstOrderWindowTest

# Полный diff каты
cat target/surefire-reports/dev.sqlkata.junior.Kata001_ActiveRuCustomersTest.txt
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

Если Docker не запущен, тесты не смогут создать контейнер. Это единственная
внешняя зависимость тренажёра.
