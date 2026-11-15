package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 020 — Заказы дороже среднего")
class Kata020_AboveAverageOrdersTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("сравнивает заказы со средним чеком через скалярный подзапрос")
    void shouldAboveAverageOrders() {
        assertKataMatches("katas/01_junior/kata_020_above_average_orders.sql");
    }
}
