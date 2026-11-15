package dev.sqlkata.senior;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import dev.sqlkata.AbstractSqlKataTest;

@DisplayName("Senior · Kata 088 — IQR-выбросы")
class Kata088_IqrOutliersTest extends AbstractSqlKataTest {

    @Test
    @DisplayName("находит выбросы стоимости позиций заказов через PERCENTILE_CONT")
    void shouldIqrOutliers() {
        assertKataMatches("katas/03_senior/kata_088_iqr_outliers.sql");
    }
}
