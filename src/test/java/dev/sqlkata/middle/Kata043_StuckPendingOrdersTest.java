package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 043 — Зависшие pending-заказы")
class Kata043_StuckPendingOrdersTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит pending-заказы с успешным платежом старше 24 часов")
    void shouldStuckPendingOrders() {
        assertKataMatches("katas/02_middle/kata_043_stuck_pending_orders.sql");
    }
}
