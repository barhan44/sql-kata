package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 060 — Пропуски в нумерации счетов")
class Kata060_InvoiceNumberGapsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит диапазоны пропущенных номеров через LEAD")
    void shouldInvoiceNumberGaps() {
        assertKataMatches("katas/03_senior/kata_060_invoice_number_gaps.sql");
    }
}
