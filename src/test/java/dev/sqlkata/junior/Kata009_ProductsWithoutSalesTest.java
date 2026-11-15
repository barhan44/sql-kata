package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 009 — Товары без продаж")
class Kata009_ProductsWithoutSalesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит товары, отсутствующие в позициях любых заказов")
    void shouldProductsWithoutSales() {
        assertKataMatches("katas/01_junior/kata_009_products_without_sales.sql");
    }
}
