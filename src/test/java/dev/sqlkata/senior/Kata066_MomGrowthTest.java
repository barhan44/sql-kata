package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 066 — Month-over-Month рост")
class Kata066_MomGrowthTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает MoM-рост выручки с нулевыми месяцами через generate_series и LAG")
    void shouldMomGrowth() {
        assertKataMatches("katas/03_senior/kata_066_mom_growth.sql");
    }
}
