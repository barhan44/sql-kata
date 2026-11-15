package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 017 — Эффективность уровней лояльности")
class Kata017_LoyaltyTierPerformanceTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("сохраняет уровни без доставленных заказов через LEFT JOIN")
    void shouldLoyaltyTierPerformance() {
        assertKataMatches("katas/01_junior/kata_017_loyalty_tier_performance.sql");
    }
}
