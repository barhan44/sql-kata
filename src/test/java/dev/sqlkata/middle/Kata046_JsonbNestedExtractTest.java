package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 046 — Вложенные поля JSONB")
class Kata046_JsonbNestedExtractTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("извлекает вложенные атрибуты и безопасно приводит attempt к integer")
    void shouldJsonbNestedExtract() {
        assertKataMatches("katas/02_middle/kata_046_jsonb_nested_extract.sql");
    }
}
