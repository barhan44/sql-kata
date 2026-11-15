package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 071 — Фонд оплаты ветки")
class Kata071_OrgSubtreePayrollTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает подчинённых и payroll в организационном поддереве")
    void shouldOrgSubtreePayroll() {
        assertKataMatches("katas/03_senior/kata_071_org_subtree_payroll.sql");
    }
}
