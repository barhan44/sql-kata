package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 093 — SARGable-арифметика")
class Kata093_SargableArithmeticTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("переписывает выражение над amount в сравнение с константой и использует индекс")
    void shouldSargableArithmetic() {
        assertKataMatches("katas/04_pro_tuning/kata_093_sargable_arithmetic.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_093_sargable_arithmetic.sql", "events_big_amount_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_093_sargable_arithmetic.sql", "events_big");
    }
}
