package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 103 — Pre-aggregation")
class Kata103_PreaggregationBeforeJoinTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("устраняет декартов взрыв перед JOIN")
    void shouldPreaggregationBeforeJoin() {
        assertKataMatches("katas/04_pro_tuning/kata_103_preaggregation_before_join.sql");
    }
}
