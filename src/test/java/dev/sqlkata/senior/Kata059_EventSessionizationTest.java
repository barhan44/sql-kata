package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 059 — Sessionization событий")
class Kata059_EventSessionizationTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("нарезает поток событий на сессии по 30-минутному таймауту")
    void shouldEventSessionization() {
        assertKataMatches("katas/03_senior/kata_059_event_sessionization.sql");
    }
}
