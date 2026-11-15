package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 070 — Выручка поддеревьев")
class Kata070_SubtreeRevenueTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("суммирует доставленную выручку по всем потомкам категории")
    void shouldSubtreeRevenue() {
        assertKataMatches("katas/03_senior/kata_070_subtree_revenue.sql");
    }
}
