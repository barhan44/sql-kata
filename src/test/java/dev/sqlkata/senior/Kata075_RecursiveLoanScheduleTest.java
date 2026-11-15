package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 075 — График погашения кредита")
class Kata075_RecursiveLoanScheduleTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("строит рекурсивный график платежей с процентами")
    void shouldRecursiveLoanSchedule() {
        assertKataMatches("katas/03_senior/kata_075_recursive_loan_schedule.sql");
    }
}
