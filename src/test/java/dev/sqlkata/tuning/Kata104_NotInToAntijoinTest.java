package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 104 — NOT IN → Anti-Join")
class Kata104_NotInToAntijoinTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("решает NULL-ловушку через NOT EXISTS")
    void shouldNotInToAntijoin() {
        assertKataMatches("katas/04_pro_tuning/kata_104_not_in_to_antijoin.sql");
    }
}
