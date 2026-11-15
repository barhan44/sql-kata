package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 081 — GROUPING SETS")
class Kata081_GroupingSetsRevenueTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("строит многомерные итоги выручки по региону и категории")
    void shouldGroupingSetsRevenue() {
        assertKataMatches("katas/03_senior/kata_081_grouping_sets_revenue.sql");
    }
}
