package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 024 — Уникальные email-домены")
class Kata024_UniqueEmailDomainsTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("объединяет домены клиентов и сотрудников через UNION")
    void shouldUniqueEmailDomains() {
        assertKataMatches("katas/01_junior/kata_024_unique_email_domains.sql");
    }
}
