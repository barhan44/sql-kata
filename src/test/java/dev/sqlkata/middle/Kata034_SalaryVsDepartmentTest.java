package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 034 — Зарплата и статистика отдела")
class Kata034_SalaryVsDepartmentTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("сравнивает сотрудника со средней, максимумом и топом отдела")
    void shouldSalaryVsDepartment() {
        assertKataMatches("katas/02_middle/kata_034_salary_vs_department.sql");
    }
}
