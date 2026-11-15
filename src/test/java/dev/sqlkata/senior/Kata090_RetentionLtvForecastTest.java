package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 090 — Retention и LTV-прогноз")
class Kata090_RetentionLtvForecastTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("строит когортную витрину с циклами, LATERAL и накоплением LTV")
    void shouldRetentionLtvForecast() {
        assertKataMatches("katas/03_senior/kata_090_retention_ltv_forecast.sql");
    }
}
