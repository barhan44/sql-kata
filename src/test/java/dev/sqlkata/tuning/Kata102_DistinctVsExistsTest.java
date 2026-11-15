package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 102 — DISTINCT → EXISTS")
class Kata102_DistinctVsExistsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("заменяет DISTINCT после JOIN на semi-join")
    void shouldDistinctVsExists() {
        assertKataMatches("katas/04_pro_tuning/kata_102_distinct_vs_exists.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_102_distinct_vs_exists.sql", "events_big_event_type_user_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_102_distinct_vs_exists.sql", "events_big");
    }
}
