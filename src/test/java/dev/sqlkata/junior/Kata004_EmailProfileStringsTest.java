package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 004 — Строковые функции в профиле")
class Kata004_EmailProfileStringsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("нормализует email, извлекает домен и переводит имя в верхний регистр")
    void shouldEmailProfileStrings() {
        assertKataMatches("katas/01_junior/kata_004_email_profile_strings.sql");
    }
}
