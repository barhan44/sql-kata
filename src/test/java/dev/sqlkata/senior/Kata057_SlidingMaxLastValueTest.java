package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 057 — Скользящий максимум и LAST_VALUE")
class Kata057_SlidingMaxLastValueTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("сравнивает заказ с последними тремя и последним заказом клиента")
    void shouldSlidingMaxLastValue() {
        assertKataMatches("katas/03_senior/kata_057_sliding_max_last_value.sql");
    }
}
