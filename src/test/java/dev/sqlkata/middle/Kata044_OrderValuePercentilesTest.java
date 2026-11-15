package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 044 — Медиана и P95 по категориям")
class Kata044_OrderValuePercentilesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает PERCENTILE_CONT по стоимости заказов в категории")
    void shouldOrderValuePercentiles() {
        assertKataMatches("katas/02_middle/kata_044_order_value_percentiles.sql");
    }
}
