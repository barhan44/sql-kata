package dev.sqlkata.middle;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Middle · Kata 055 — RFM-сегментация клиентов")
class Kata055_RfmSegmentationTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("строит RFM-скоры через NTILE и агрегирует сегменты")
    void shouldRfmSegmentation() {
        assertKataMatches("katas/02_middle/kata_055_rfm_segmentation.sql");
    }
}
