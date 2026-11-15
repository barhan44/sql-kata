package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 068 — Пути к листьям категорий")
class Kata068_CategoryLeafPathsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("строит root-to-leaf пути дерева категорий")
    void shouldCategoryLeafPaths() {
        assertKataMatches("katas/03_senior/kata_068_category_leaf_paths.sql");
    }
}
