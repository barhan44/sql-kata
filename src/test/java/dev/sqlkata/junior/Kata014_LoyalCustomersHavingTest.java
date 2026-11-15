package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 014 — Постоянные клиенты")
class Kata014_LoyalCustomersHavingTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("фильтрует агрегаты через HAVING по числу заказов и сумме")
    void shouldLoyalCustomersHaving() {
        assertKataMatches("katas/01_junior/kata_014_loyal_customers_having.sql");
    }
}
