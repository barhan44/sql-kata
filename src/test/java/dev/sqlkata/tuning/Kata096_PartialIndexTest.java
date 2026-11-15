package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 096 — Частичный индекс")
class Kata096_PartialIndexTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("попадает в предикат частичного индекса для NEW-событий")
    void shouldPartialIndex() {
        assertKataMatches("katas/04_pro_tuning/kata_096_partial_index.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_096_partial_index.sql", "events_big_new_retry_partial_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_096_partial_index.sql", "events_big");
    }
}
