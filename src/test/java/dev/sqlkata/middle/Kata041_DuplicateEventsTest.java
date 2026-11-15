package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 041 — Дубликаты событий")
class Kata041_DuplicateEventsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит повторные audit-события в пределах минуты")
    void shouldDuplicateEvents() {
        assertKataMatches("katas/02_middle/kata_041_duplicate_events.sql");
    }
}
