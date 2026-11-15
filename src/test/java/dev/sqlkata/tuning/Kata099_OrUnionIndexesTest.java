package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 099 — OR через UNION ALL")
class Kata099_OrUnionIndexesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("использует два индексных маршрута и сохраняет дедупликацию")
    void shouldOrUnionIndexes() {
        assertKataMatches("katas/04_pro_tuning/kata_099_or_union_indexes.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_099_or_union_indexes.sql", "events_big_user_status_idx");
        assertUsesIndex("katas/04_pro_tuning/kata_099_or_union_indexes.sql", "events_big_merchant_status_created_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_099_or_union_indexes.sql", "events_big");
    }
}
