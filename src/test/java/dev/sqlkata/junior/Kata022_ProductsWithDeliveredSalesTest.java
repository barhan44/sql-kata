package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 022 — Товары с доставленными продажами")
class Kata022_ProductsWithDeliveredSalesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("проверяет наличие доставленной продажи через EXISTS")
    void shouldProductsWithDeliveredSales() {
        assertKataMatches("katas/01_junior/kata_022_products_with_delivered_sales.sql");
    }
}
