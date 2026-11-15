package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 019 — Активность сессий по дням")
class Kata019_DailySessionActivityTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("строит дневной pivot по устройствам через CASE WHEN")
    void shouldDailySessionActivity() {
        assertKataMatches("katas/01_junior/kata_019_daily_session_activity.sql");
    }
}
