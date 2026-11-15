package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 051 — Непрерывный календарь продаж")
class Kata051_CalendarGapsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("заполняет нулями дни июня без доставленных заказов")
    void shouldCalendarGaps() {
        assertKataMatches("katas/02_middle/kata_051_calendar_gaps.sql");
    }
}
