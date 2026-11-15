package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 050 — Нативные массивы PostgreSQL")
class Kata050_NativeArraysTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("использует &&, ANY, unnest и array_agg для тегов товаров")
    void shouldNativeArrays() {
        assertKataMatches("katas/02_middle/kata_050_native_arrays.sql");
    }
}
