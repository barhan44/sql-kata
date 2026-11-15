package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 025 — Первый заказ в первые 30 дней")
class Kata025_FirstOrderWindowTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("использует DATE_TRUNC и INTERVAL для когортного окна")
    void shouldFirstOrderWindow() {
        assertKataMatches("katas/01_junior/kata_025_first_order_window.sql");
    }
}
