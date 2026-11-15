package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 018 — Доля возвратов по товарам")
class Kata018_ProductReturnsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("считает возвращённые единицы и их долю через условную агрегацию")
    void shouldProductReturns() {
        assertKataMatches("katas/01_junior/kata_018_product_returns.sql");
    }
}
