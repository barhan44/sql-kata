package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 033 — Квартили LTV клиентов")
class Kata033_CustomerLtvQuartilesTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("распределяет клиентов по NTILE(4) и выделяет VIP-квартиль")
    void shouldCustomerLtvQuartiles() {
        assertKataMatches("katas/02_middle/kata_033_customer_ltv_quartiles.sql");
    }
}
