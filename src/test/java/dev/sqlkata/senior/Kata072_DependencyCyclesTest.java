package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 072 — Циклы зависимостей")
class Kata072_DependencyCyclesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит циклы в графе задач через массив путей")
    void shouldDependencyCycles() {
        assertKataMatches("katas/03_senior/kata_072_dependency_cycles.sql");
    }
}
