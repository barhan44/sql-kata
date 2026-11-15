package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 058 — Серии ежедневных логинов")
class Kata058_LoginStreaksTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит непрерывные серии логинов от трёх дней через gaps and islands")
    void shouldLoginStreaks() {
        assertKataMatches("katas/03_senior/kata_058_login_streaks.sql");
    }
}
