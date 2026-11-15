package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 101 — Устранение N+1")
class Kata101_EliminateCorrelatedSubqueriesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("заменяет три коррелированных подзапроса одним pre-aggregation")
    void shouldEliminateCorrelatedSubqueries() {
        assertKataMatches("katas/04_pro_tuning/kata_101_eliminate_correlated_subqueries.sql");
    }
}
