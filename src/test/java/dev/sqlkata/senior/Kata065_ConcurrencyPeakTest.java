package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 065 — Пик одновременных сессий")
class Kata065_ConcurrencyPeakTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("вычисляет максимальную одновременную нагрузку по событиям входа/выхода")
    void shouldConcurrencyPeak() {
        assertKataMatches("katas/03_senior/kata_065_concurrency_peak.sql");
    }
}
