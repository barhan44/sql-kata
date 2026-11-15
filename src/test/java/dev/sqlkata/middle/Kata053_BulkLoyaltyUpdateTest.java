package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 053 — Массовое обновление статусов")
class Kata053_BulkLoyaltyUpdateTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("пересчитывает loyalty_tier через UPDATE FROM с RETURNING")
    void shouldBulkLoyaltyUpdate() {
        assertKataMatches("katas/02_middle/kata_053_bulk_loyalty_update.sql");
    }
}
