package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 089 — Keyset Pagination")
class Kata089_KeysetPaginationTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("делает страницу по составному курсору без OFFSET")
    void shouldKeysetPagination() {
        assertKataMatches("katas/03_senior/kata_089_keyset_pagination.sql");
    }
}
