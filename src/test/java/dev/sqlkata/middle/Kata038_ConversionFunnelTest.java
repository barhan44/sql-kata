package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 038 — Воронка конверсии")
class Kata038_ConversionFunnelTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает этапы registered → first_order → paid → repeat_order через CTE")
    void shouldConversionFunnel() {
        assertKataMatches("katas/02_middle/kata_038_conversion_funnel.sql");
    }
}
