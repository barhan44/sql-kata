package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 029 — Сравнение заказа с предыдущим")
class Kata029_OrderLagComparisonTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("вычисляет разницу суммы и времени через LAG")
    void shouldOrderLagComparison() {
        assertKataMatches("katas/02_middle/kata_029_order_lag_comparison.sql");
    }
}
