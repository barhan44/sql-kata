package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 062 — Первый овердрафт")
class Kata062_OverdraftDetectionTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит первую транзакцию с отрицательным накопительным балансом")
    void shouldOverdraftDetection() {
        assertKataMatches("katas/03_senior/kata_062_overdraft_detection.sql");
    }
}
