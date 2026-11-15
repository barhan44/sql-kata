package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 030 — Следующая сессия пользователя")
class Kata030_SessionLeadForecastTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("прогнозирует следующую сессию через LEAD и считает длительность")
    void shouldSessionLeadForecast() {
        assertKataMatches("katas/02_middle/kata_030_session_lead_forecast.sql");
    }
}
