package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 105 — Захват очереди SKIP LOCKED")
class Kata105_SkipLockedQueueTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("проверяет два параллельных воркера и непересекающиеся пачки")
    void shouldSkipLockedQueue() {
        assertSkipLocked("katas/04_pro_tuning/kata_105_skip_locked_queue.sql", 10);
    }
}
