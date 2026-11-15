package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 107 — Оптимистичная блокировка")
class Kata107_OptimisticLockingTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("отклоняет списание при недостатке баланса и неверной версии")
    void shouldOptimisticLocking() {
        assertKataMatches("katas/04_pro_tuning/kata_107_optimistic_locking.sql");
    }
}
