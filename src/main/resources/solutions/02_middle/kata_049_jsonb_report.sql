-- =============================================================================
-- KATA 049 · Эталонное решение
-- =============================================================================
-- Почему так:
--   • product_sales — базовый агрегат по категории и товару.
--   • ranked через ROW_NUMBER гарантирует не более трёх товаров на категорию,
--     даже если у нескольких товаров одинаковая выручка. ROW_NUMBER с
--     tie-breaker product_id даёт строгий Top-3.
--   • categories агрегирует выручку всей категории, а FILTER (WHERE position<=3)
--     ограничивает содержимое top_products. Это дешевле, чем отдельный JOIN
--     с предварительно отфильтрованным Top-3.
--   • jsonb_build_object строит объекты, jsonb_agg — массивы. ORDER BY внутри
--     агрегата фиксирует порядок элементов JSON, что важно для API и тестов.
--   • Один запрос возвращает ровно одну строку с jsonb-колонкой: приложение
--     не делает N+1 запросов и не собирает отчёт в памяти.
--   • Индексы order_items(order_id), order_items(product_id) и
--     orders(status, created_at) помогают базовой агрегации.
-- =============================================================================

WITH product_sales AS (
    SELECT
        c.category_id,
        c.name AS category_name,
        p.product_id,
        p.name AS product_name,
        sum(oi.quantity) AS units,
        sum(oi.line_total) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN categories c ON c.category_id = p.category_id
    WHERE o.status = 'delivered'
    GROUP BY c.category_id, c.name, p.product_id, p.name
),
ranked AS (
    SELECT
        *,
        row_number() OVER (
            PARTITION BY category_id
            ORDER BY revenue DESC, product_id ASC
        ) AS product_position
    FROM product_sales
),
categories AS (
    SELECT
        category_id,
        category_name,
        sum(revenue) AS revenue,
        sum(units) AS units,
        jsonb_agg(
            jsonb_build_object(
                'product_id', product_id,
                'name', product_name,
                'units', units,
                'revenue', revenue
            )
            ORDER BY revenue DESC, product_id ASC
        ) FILTER (WHERE product_position <= 3) AS top_products
    FROM ranked
    GROUP BY category_id, category_name
),
report AS (
    SELECT jsonb_build_object(
        'as_of_date', '2024-06-30',
        'currency', 'RUB',
        'categories', jsonb_agg(
            jsonb_build_object(
                'category_id', category_id,
                'category', category_name,
                'revenue', revenue,
                'units', units,
                'top_products', top_products
            )
            ORDER BY revenue DESC, category_name ASC
        )
    ) AS report
    FROM categories
)
SELECT report
FROM report;
