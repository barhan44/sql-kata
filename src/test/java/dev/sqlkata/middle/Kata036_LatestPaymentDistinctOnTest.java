package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 036 — Последний платёж пользователя")
class Kata036_LatestPaymentDistinctOnTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("выбирает последний успешный платёж через DISTINCT ON")
    void shouldLatestPaymentDistinctOn() {
        assertKataMatches("katas/02_middle/kata_036_latest_payment_distinct_on.sql");
    }
}
