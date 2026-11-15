package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 052 — UPSERT товара")
class Kata052_ProductUpsertTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("выполняет INSERT ON CONFLICT DO UPDATE с EXCLUDED и RETURNING *")
    void shouldProductUpsert() {
        assertKataMatches("katas/02_middle/kata_052_product_upsert.sql");
    }
}
