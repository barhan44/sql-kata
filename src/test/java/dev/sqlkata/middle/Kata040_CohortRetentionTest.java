package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 040 — Когортный retention")
class Kata040_CohortRetentionTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает retention первых трёх месяцев по когортам регистрации")
    void shouldCohortRetention() {
        assertKataMatches("katas/02_middle/kata_040_cohort_retention.sql");
    }
}
