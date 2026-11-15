package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 039 — Смартфоны без аудио")
class Kata039_CategoryExceptTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит покупателей категории A, не покупавших категорию B, через EXCEPT")
    void shouldCategoryExcept() {
        assertKataMatches("katas/02_middle/kata_039_category_except.sql");
    }
}
