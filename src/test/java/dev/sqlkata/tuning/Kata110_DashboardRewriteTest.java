package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 110 — Финальный дашборд")
class Kata110_DashboardRewriteTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("устраняет не-SARGable дату, DISTINCT, N+1 и OFFSET в одном запросе")
    void shouldDashboardRewrite() {
        assertKataMatches("katas/04_pro_tuning/kata_110_dashboard_rewrite.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_110_dashboard_rewrite.sql", "events_big_status_created_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_110_dashboard_rewrite.sql", "events_big");
    }
}
