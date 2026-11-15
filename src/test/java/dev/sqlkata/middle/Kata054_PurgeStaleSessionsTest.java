package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 054 — Удаление устаревших сессий")
class Kata054_PurgeStaleSessionsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("удаляет сессии неактивных пользователей через DELETE USING")
    void shouldPurgeStaleSessions() {
        assertKataMatches("katas/02_middle/kata_054_purge_stale_sessions.sql");
    }
}
