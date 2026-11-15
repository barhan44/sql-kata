package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 087 — Market Basket Analysis")
class Kata087_MarketBasketTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит пары совместно купленных товаров")
    void shouldMarketBasket() {
        assertKataMatches("katas/03_senior/kata_087_market_basket.sql");
    }
}
