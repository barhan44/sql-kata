package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 035 — Аномальные скачки трат")
class Kata035_SpendingAnomaliesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит заказы более чем в два раза выше среднего предыдущих")
    void shouldSpendingAnomalies() {
        assertKataMatches("katas/02_middle/kata_035_spending_anomalies.sql");
    }
}
