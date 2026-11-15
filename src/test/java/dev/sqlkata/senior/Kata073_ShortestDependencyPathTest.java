package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 073 — Кратчайший путь зависимостей")
class Kata073_ShortestDependencyPathTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("ищет BFS-путь в графе задач с SEARCH BREADTH FIRST")
    void shouldShortestDependencyPath() {
        assertKataMatches("katas/03_senior/kata_073_shortest_dependency_path.sql");
    }
}
