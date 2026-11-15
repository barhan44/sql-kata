package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 013 — Продажи по категориям")
class Kata013_CategorySalesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("агрегирует уникальные заказы, единицы и выручку по категориям")
    void shouldCategorySales() {
        assertKataMatches("katas/01_junior/kata_013_category_sales.sql");
    }
}
