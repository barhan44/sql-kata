package dev.sqlkata.tuning;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Pro · Kata 106 — Идемпотентный вебхук")
class Kata106_IdempotentWebhookTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("не вставляет повторное событие через ON CONFLICT DO NOTHING")
    void shouldIdempotentWebhook() {
        assertKataMatches("katas/04_pro_tuning/kata_106_idempotent_webhook.sql");
    }
}
