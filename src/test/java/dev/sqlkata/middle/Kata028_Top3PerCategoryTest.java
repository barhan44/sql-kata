package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 028 — Топ-3 товара в категории")
class Kata028_Top3PerCategoryTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит три самых дорогих активных товара каждой категории через DENSE_RANK")
    void shouldTop3PerCategory() {
        assertKataMatches("katas/02_middle/kata_028_top3_per_category.sql");
    }
}
