package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 091 — SARGable-фильтр по дате")
class Kata091_SargableDateFilterTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("переписывает DATE(created_at) в полуоткрытый диапазон и использует индекс")
    void shouldSargableDateFilter() {
        assertKataMatches("katas/04_pro_tuning/kata_091_sargable_date_filter.sql");
        assertUsesIndex("katas/04_pro_tuning/kata_091_sargable_date_filter.sql", "events_big_created_at_idx");
        assertNoSeqScan("katas/04_pro_tuning/kata_091_sargable_date_filter.sql", "events_big");
    }
}
