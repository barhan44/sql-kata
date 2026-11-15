package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 094 — Составной индекс")
class Kata094_CompositeIndexOrderTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("использует (status, created_at) по правилу equality-first")
    void shouldCompositeIndexOrder() {
        assertKataMatches("katas/04_pro_tuning/kata_094_composite_index_order.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_094_composite_index_order.sql", "events_big_status_created_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_094_composite_index_order.sql", "events_big");
    }
}
