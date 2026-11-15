package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 077 — Целостность staging-дерева")
class Kata077_TreeIntegrityTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит сирот и превышение глубины дерева")
    void shouldTreeIntegrity() {
        assertKataMatches("katas/03_senior/kata_077_tree_integrity.sql");
    }
}
