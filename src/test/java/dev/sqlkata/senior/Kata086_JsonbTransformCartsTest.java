package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 086 — JSONB-преобразование корзин")
class Kata086_JsonbTransformCartsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("очищает и обогащает JSONB через jsonb_set и операторы")
    void shouldJsonbTransformCarts() {
        assertKataMatches("katas/03_senior/kata_086_jsonb_transform_carts.sql");
    }
}
