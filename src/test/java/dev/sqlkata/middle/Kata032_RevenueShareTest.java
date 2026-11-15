package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 032 — Доля товара в выручке")
class Kata032_RevenueShareTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает доли товара в категории и по всему магазину через окна")
    void shouldRevenueShare() {
        assertKataMatches("katas/02_middle/kata_032_revenue_share.sql");
    }
}
