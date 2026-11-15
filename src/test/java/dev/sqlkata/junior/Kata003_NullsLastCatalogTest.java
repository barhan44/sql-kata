package dev.sqlkata.junior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Junior · Kata 003 — Витрина каталога с NULLS LAST")
class Kata003_NullsLastCatalogTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("ставит товары с неизвестным рейтингом и остатком в конец")
    void shouldNullsLastCatalog() {
        assertKataMatches("katas/01_junior/kata_003_nulls_last_catalog.sql");
    }
}
