package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 097 — GIN по JSONB")
class Kata097_JsonbGinTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("использует containment и GIN-индекс metadata")
    void shouldJsonbGin() {
        assertKataMatches("katas/04_pro_tuning/kata_097_jsonb_gin.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_097_jsonb_gin.sql", "events_big_metadata_gin_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_097_jsonb_gin.sql", "events_big");
    }
}
