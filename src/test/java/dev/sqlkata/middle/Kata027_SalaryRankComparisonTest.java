package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 027 — Сравнение функций ранжирования")
class Kata027_SalaryRankComparisonTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("показывает различие ROW_NUMBER, RANK и DENSE_RANK при равных зарплатах")
    void shouldSalaryRankComparison() {
        assertKataMatches("katas/02_middle/kata_027_salary_rank_comparison.sql");
    }
}
