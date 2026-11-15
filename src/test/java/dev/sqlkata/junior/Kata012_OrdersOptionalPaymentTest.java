package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 012 — Заказы и необязательный платёж")
class Kata012_OrdersOptionalPaymentTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("присоединяет captured-платёж так, чтобы неоплаченные заказы не исчезли")
    void shouldOrdersOptionalPayment() {
        assertKataMatches("katas/01_junior/kata_012_orders_optional_payment.sql");
    }
}
