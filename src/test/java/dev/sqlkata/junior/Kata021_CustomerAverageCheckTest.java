package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 021 — Средний чек клиента")
class Kata021_CustomerAverageCheckTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("фильтрует клиентов по среднему чеку из подзапроса в FROM")
    void shouldCustomerAverageCheck() {
        assertKataMatches("katas/01_junior/kata_021_customer_average_check.sql");
    }
}
