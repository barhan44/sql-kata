package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 074 — Разбиение подписок по месяцам")
class Kata074_SubscriptionMonthSplitTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("разворачивает периоды подписок и пропорционально делит сумму")
    void shouldSubscriptionMonthSplit() {
        assertKataMatches("katas/03_senior/kata_074_subscription_month_split.sql");
    }
}
