package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 100 — EXISTS вместо COUNT")
class Kata100_ExistsInsteadOfCountTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("проверяет существование через semi-join и индекс")
    void shouldExistsInsteadOfCount() {
        assertKataMatches("katas/04_pro_tuning/kata_100_exists_instead_of_count.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_100_exists_instead_of_count.sql", "events_big_user_status_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_100_exists_instead_of_count.sql", "events_big");
    }
}
