package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 005 — Маржинальность и стоимость склада")
class Kata005_ProductMarginsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает маржу, процент маржи и стоимость остатков")
    void shouldProductMargins() {
        assertKataMatches("katas/01_junior/kata_005_product_margins.sql");
    }
}
