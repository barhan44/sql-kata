package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 109 — Фильтр до окна")
class Kata109_FilterBeforeWindowTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("переносит фильтрацию до WindowAgg и использует покрывающий индекс")
    void shouldFilterBeforeWindow() {
        assertKataMatches("katas/04_pro_tuning/kata_109_filter_before_window.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_109_filter_before_window.sql", "events_big_merchant_status_created_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_109_filter_before_window.sql", "events_big");
    }
}
