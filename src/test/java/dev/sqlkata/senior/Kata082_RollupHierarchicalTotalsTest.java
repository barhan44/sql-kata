package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 082 — ROLLUP-итоги")
class Kata082_RollupHierarchicalTotalsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("строит иерархические итоги year → quarter → month")
    void shouldRollupHierarchicalTotals() {
        assertKataMatches("katas/03_senior/kata_082_rollup_hierarchical_totals.sql");
    }
}
