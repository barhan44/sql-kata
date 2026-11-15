package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 079 — Top-2 через LATERAL")
class Kata079_LateralTop2Test extends AbstractSqlKataTest {

    @Test
    @DisplayName("выбирает два самых дорогих товара каждой категории через CROSS JOIN LATERAL")
    void shouldLateralTop2() {
        assertKataMatches("katas/03_senior/kata_079_lateral_top2.sql");
    }
}
