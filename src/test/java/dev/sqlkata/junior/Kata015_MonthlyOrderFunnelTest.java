package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 015 — Месячная воронка заказов")
class Kata015_MonthlyOrderFunnelTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает статусы по месяцам условной агрегацией CASE WHEN")
    void shouldMonthlyOrderFunnel() {
        assertKataMatches("katas/01_junior/kata_015_monthly_order_funnel.sql");
    }
}
