package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 108 — Батчевое удаление")
class Kata108_BatchDeleteTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("удаляет 500 старых событий через CTE и SKIP LOCKED")
    void shouldBatchDelete() {
        assertKataMatches("katas/04_pro_tuning/kata_108_batch_delete.sql");
    }
}
