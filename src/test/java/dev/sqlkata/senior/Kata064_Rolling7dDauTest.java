package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 064 — Rolling 7-day DAU")
class Kata064_Rolling7dDauTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает уникальных активных пользователей за скользящие 7 дней")
    void shouldRolling7dDau() {
        assertKataMatches("katas/03_senior/kata_064_rolling_7d_dau.sql");
    }
}
