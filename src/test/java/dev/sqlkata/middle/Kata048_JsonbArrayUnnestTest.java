package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 048 — Статистика по JSON-тегам")
class Kata048_JsonbArrayUnnestTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("разворачивает JSON-массив тегов и агрегирует события")
    void shouldJsonbArrayUnnest() {
        assertKataMatches("katas/02_middle/kata_048_jsonb_array_unnest.sql");
    }
}
