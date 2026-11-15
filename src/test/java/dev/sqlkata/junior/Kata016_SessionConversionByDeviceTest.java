package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 016 — Конверсия сессий по устройствам")
class Kata016_SessionConversionByDeviceTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("безопасно делит на количество сессий через NULLIF")
    void shouldSessionConversionByDevice() {
        assertKataMatches("katas/01_junior/kata_016_session_conversion_by_device.sql");
    }
}
