package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 085 — SQL/JSON Path")
class Kata085_JsonPathCartsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("фильтрует JSONB-корзины через jsonb_path_exists")
    void shouldJsonPathCarts() {
        assertKataMatches("katas/03_senior/kata_085_json_path_carts.sql");
    }
}
