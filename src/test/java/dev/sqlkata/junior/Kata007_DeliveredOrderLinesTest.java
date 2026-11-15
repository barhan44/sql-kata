package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 007 — Позиции доставленных заказов")
class Kata007_DeliveredOrderLinesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("соединяет заказы, позиции и товары только для доставленных заказов")
    void shouldDeliveredOrderLines() {
        assertKataMatches("katas/01_junior/kata_007_delivered_order_lines.sql");
    }
}
