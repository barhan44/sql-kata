package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 092 — SARGable-поиск по email")
class Kata092_SargableEmailIndexTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("использует функциональный индекс lower(email) без ведущего процента")
    void shouldSargableEmailIndex() {
        assertKataMatches("katas/04_pro_tuning/kata_092_sargable_email_index.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_092_sargable_email_index.sql", "events_big_lower_email_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_092_sargable_email_index.sql", "events_big");
    }
}
