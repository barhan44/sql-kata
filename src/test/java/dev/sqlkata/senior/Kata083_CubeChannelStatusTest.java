package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 083 — CUBE по каналам и статусам")
class Kata083_CubeChannelStatusTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает все комбинации канала и статуса клиента")
    void shouldCubeChannelStatus() {
        assertKataMatches("katas/03_senior/kata_083_cube_channel_status.sql");
    }
}
