package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 049 — JSON-отчёт по категориям")
class Kata049_JsonbReportTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("собирает вложенный JSON-отчёт через jsonb_build_object и jsonb_agg")
    void shouldJsonbReport() {
        assertKataMatches("katas/02_middle/kata_049_jsonb_report.sql");
    }
}
