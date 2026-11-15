package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 008 — Клиенты без заказов")
class Kata008_UsersWithoutOrdersTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит пользователей без единого заказа через anti-join")
    void shouldUsersWithoutOrders() {
        assertKataMatches("katas/01_junior/kata_008_users_without_orders.sql");
    }
}
