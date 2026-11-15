package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 056 — Скользящее среднее 7 дней")
class Kata056_Rolling7dAverageTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает 7-дневную среднюю выручку через RANGE-фрейм")
    void shouldRolling7dAverage() {
        assertKataMatches("katas/03_senior/kata_056_rolling_7d_average.sql");
    }
}
