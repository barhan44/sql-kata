package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 031 — Накопительная выручка по дням")
class Kata031_RunningTotalRevenueTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("строит running total чистого денежного потока")
    void shouldRunningTotalRevenue() {
        assertKataMatches("katas/02_middle/kata_031_running_total_revenue.sql");
    }
}
