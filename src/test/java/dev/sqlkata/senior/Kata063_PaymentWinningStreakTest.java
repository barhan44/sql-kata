package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 063 — Серия успешных платежей")
class Kata063_PaymentWinningStreakTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит самую длинную серию captured-платежей клиента")
    void shouldPaymentWinningStreak() {
        assertKataMatches("katas/03_senior/kata_063_payment_winning_streak.sql");
    }
}
