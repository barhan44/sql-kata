package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 067 — Именованные окна")
class Kata067_NamedWindowsMetricsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("рассчитывает четыре оконные метрики через WINDOW-секцию")
    void shouldNamedWindowsMetrics() {
        assertKataMatches("katas/03_senior/kata_067_named_windows_metrics.sql");
    }
}
