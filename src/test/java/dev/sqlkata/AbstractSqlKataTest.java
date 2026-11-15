package dev.sqlkata;

import java.time.Duration;

import org.testcontainers.containers.PostgreSQLContainer;

/**
 * Базовый класс всех кат.
 *
 * <p>Контейнер PostgreSQL поднимается ровно один раз на JVM. Maven Surefire
 * настроен на {@code forkCount=1} и {@code reuseForks=true}, поэтому все тесты
 * используют один и тот же экземпляр базы. Схема загружается при старте
 * контейнера из {@code schema/01_init_schema.sql}.</p>
 *
 * <p>Проверяемые SQL-запросы выполняются в транзакциях с откатом, поэтому
 * даже {@code UPDATE}/{@code DELETE}/{@code INSERT ... RETURNING} не меняют
 * общее состояние базы между тестами.</p>
 */
public abstract class AbstractSqlKataTest {

    private static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16-alpine")
                    .withDatabaseName("sqlkata")
                    .withUsername("kata")
                    .withPassword("kata")
                    .withInitScripts(
                            "schema/01_init_schema.sql",
                            "schema/02_middle_seed.sql")
                    .withStartupTimeout(Duration.ofMinutes(3));

    private static final SqlKataVerifier VERIFIER;

    static {
        POSTGRES.start();
        Runtime.getRuntime().addShutdownHook(
                new Thread(POSTGRES::stop, "sql-kata-postgres-shutdown"));
        VERIFIER = new SqlKataVerifier(
                POSTGRES.getJdbcUrl(),
                POSTGRES.getUsername(),
                POSTGRES.getPassword());
    }

    protected AbstractSqlKataTest() {
        // Только для наследования.
    }

    /**
     * Сверяет решение из {@code katas/...} с эталоном из {@code solutions/...}.
     *
     * @param kataResource путь к файлу каты в classpath
     *                     (например, {@code katas/01_junior/kata_001_active_ru_customers.sql})
     */
    protected static void assertKataMatches(String kataResource) {
        VERIFIER.assertKataMatches(kataResource);
    }
}
