package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 080 — Заказ после события")
class Kata080_LateralOrderAfterEventTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("ищет первый заказ после логина через LEFT JOIN LATERAL")
    void shouldLateralOrderAfterEvent() {
        assertKataMatches("katas/03_senior/kata_080_lateral_order_after_event.sql");
    }
}
