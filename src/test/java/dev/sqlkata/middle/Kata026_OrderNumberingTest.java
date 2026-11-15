package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 026 — Нумерация заказов клиента")
class Kata026_OrderNumberingTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("нумерует заказы через ROW_NUMBER и отмечает первый и последний")
    void shouldOrderNumbering() {
        assertKataMatches("katas/02_middle/kata_026_order_numbering.sql");
    }
}
