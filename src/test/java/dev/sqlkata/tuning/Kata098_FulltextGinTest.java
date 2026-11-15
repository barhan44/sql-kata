package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 098 — Полнотекстовый GIN")
class Kata098_FulltextGinTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("использует tsvector и GIN вместо ILIKE с ведущим процентом")
    void shouldFulltextGin() {
        assertKataMatches("katas/04_pro_tuning/kata_098_fulltext_gin.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_098_fulltext_gin.sql", "events_big_search_gin_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_098_fulltext_gin.sql", "events_big");
    }
}
