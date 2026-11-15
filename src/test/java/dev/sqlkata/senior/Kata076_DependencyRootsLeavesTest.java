package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 076 — Корни и листья зависимостей")
class Kata076_DependencyRootsLeavesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("собирает корневые предки и листья графа задач")
    void shouldDependencyRootsLeaves() {
        assertKataMatches("katas/03_senior/kata_076_dependency_roots_leaves.sql");
    }
}
