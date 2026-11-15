package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 001 — Активные клиенты из России")
class Kata001_ActiveRuCustomersTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("возвращает активных клиентов из РФ, зарегистрированных с 2022 года")
    void shouldActiveRuCustomers() {
        assertKataMatches("katas/01_junior/kata_001_active_ru_customers.sql");
    }
}
