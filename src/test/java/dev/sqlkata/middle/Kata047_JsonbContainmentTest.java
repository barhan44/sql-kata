package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 047 — Поиск по JSONB containment")
class Kata047_JsonbContainmentTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит клиентов по подструктуре preferences через @>")
    void shouldJsonbContainment() {
        assertKataMatches("katas/02_middle/kata_047_jsonb_containment.sql");
    }
}
