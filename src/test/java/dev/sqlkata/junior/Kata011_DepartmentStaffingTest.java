package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 011 — Сверка отделов и сотрудников")
class Kata011_DepartmentStaffingTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит отдел без сотрудников и сотрудника без отдела через FULL OUTER JOIN")
    void shouldDepartmentStaffing() {
        assertKataMatches("katas/01_junior/kata_011_department_staffing.sql");
    }
}
