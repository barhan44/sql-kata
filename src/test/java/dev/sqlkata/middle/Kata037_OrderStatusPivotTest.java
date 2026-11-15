package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 037 — Матрица статусов по месяцам")
class Kata037_OrderStatusPivotTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("строит pivot статусов заказов через FILTER")
    void shouldOrderStatusPivot() {
        assertKataMatches("katas/02_middle/kata_037_order_status_pivot.sql");
    }
}
