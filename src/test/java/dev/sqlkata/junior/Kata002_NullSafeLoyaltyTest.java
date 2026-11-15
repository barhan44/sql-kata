package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 002 — NULL-безопасный уровень лояльности")
class Kata002_NullSafeLoyaltyTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("сохраняет клиентов без уровня лояльности через IS DISTINCT FROM")
    void shouldNullSafeLoyalty() {
        assertKataMatches("katas/01_junior/kata_002_null_safe_loyalty.sql");
    }
}
