package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 069 — Восходящие пути категорий")
class Kata069_CategoryAncestorsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("поднимается рекурсивно от категорий товаров к корню")
    void shouldCategoryAncestors() {
        assertKataMatches("katas/03_senior/kata_069_category_ancestors.sql");
    }
}
