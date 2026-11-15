package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 061 — Слияние интервалов")
class Kata061_MergeIntervalsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("объединяет пересекающиеся периоды подписок без рекурсии")
    void shouldMergeIntervals() {
        assertKataMatches("katas/03_senior/kata_061_merge_intervals.sql");
    }
}
