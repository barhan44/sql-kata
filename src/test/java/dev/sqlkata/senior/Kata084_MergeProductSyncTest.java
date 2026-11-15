package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 084 — MERGE синхронизация каталога")
class Kata084_MergeProductSyncTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("синхронизирует products со staging через MERGE")
    void shouldMergeProductSync() {
        assertKataStateMatches(
                "katas/03_senior/kata_084_merge_product_sync.sql",
                "verifications/03_senior/kata_084_product_sync_state.sql");
    }
}
