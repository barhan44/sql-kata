package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 006 — Заказы вместе с клиентами")
class Kata006_OrdersWithCustomersTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("возвращает успешные заказы первого квартала с именами клиентов")
    void shouldOrdersWithCustomers() {
        assertKataMatches("katas/01_junior/kata_006_orders_with_customers.sql");
    }
}
