package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 045 — Приоритет контактов")
class Kata045_ContactPriorityTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("выбирает самый достоверный контакт через CASE и DISTINCT ON")
    void shouldContactPriority() {
        assertKataMatches("katas/02_middle/kata_045_contact_priority.sql");
    }
}
