package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 010 — Сотрудник и руководитель")
class Kata010_EmployeeManagerTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("показывает оргструктуру через SELF JOIN с сохранением топ-менеджеров")
    void shouldEmployeeManager() {
        assertKataMatches("katas/01_junior/kata_010_employee_manager.sql");
    }
}
