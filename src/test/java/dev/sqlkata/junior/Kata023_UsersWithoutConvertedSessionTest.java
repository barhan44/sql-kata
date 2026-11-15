package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 023 — Пользователи без конверсионной сессии")
class Kata023_UsersWithoutConvertedSessionTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("демонстрирует ловушку NOT IN с NULL и решает задачу через NOT EXISTS")
    void shouldUsersWithoutConvertedSession() {
        assertKataMatches("katas/01_junior/kata_023_users_without_converted_session.sql");
    }
}
