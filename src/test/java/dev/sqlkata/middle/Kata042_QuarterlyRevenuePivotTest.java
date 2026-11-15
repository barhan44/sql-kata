package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 042 — Квартальный pivot выручки")
class Kata042_QuarterlyRevenuePivotTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("строит квартальную матрицу выручки через FILTER")
    void shouldQuarterlyRevenuePivot() {
        assertKataMatches("katas/02_middle/kata_042_quarterly_revenue_pivot.sql");
    }
}
