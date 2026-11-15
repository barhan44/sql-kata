package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 078 — DFS-порядок категорий")
class Kata078_CategoryDfsOrderTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("сортирует дерево категорий в pre-order DFS")
    void shouldCategoryDfsOrder() {
        assertKataMatches("katas/03_senior/kata_078_category_dfs_order.sql");
    }
}
