package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 095 — Покрывающий индекс")
class Kata095_CoveringIndexTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("получает Index Only Scan с нулевыми Heap Fetches")
    void shouldCoveringIndex() {
        assertKataMatches("katas/04_pro_tuning/kata_095_covering_index.sql");
        assertIndexOnlyScan("katas/04_pro_tuning/kata_095_covering_index.sql", "events_big_covering_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_095_covering_index.sql", "events_big");
    }
}
