package dev.sqlkata;

import static org.assertj.core.api.Assertions.fail;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.sql.Array;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.postgresql.util.PGobject;

/**
 * Движок проверки SQL-кат.
 *
 * <p>Кандидат и эталон выполняются в отдельных транзакциях, которые всегда
 * откатываются. Сравниваются имена колонок, их SQL-типы, количество строк,
 * порядок строк и значения. Порядок строк важен: в условии каждой каты явно
 * задан {@code ORDER BY}.</p>
 *
 * <p>Если запустить тесты с {@code -DuseSolution=true}, в качестве кандидата
 * берётся эталонное решение. Это режим самопроверки всего набора кат.</p>
 *
 * <p>Для DML без {@code RETURNING} (например, {@code MERGE}) доступен режим
 * проверки состояния: после команды в той же транзакции выполняется
 * verification SELECT, и сравниваются снимки состояния кандидата и эталона.</p>
 */
public final class SqlKataVerifier {

    private static final int MAX_ROWS_IN_DIFF = 12;
    private static final Set<String> INDEX_NODE_TYPES = Set.of(
            "Index Scan", "Index Only Scan", "Bitmap Index Scan");
    private static final ObjectMapper JSON_MAPPER = new ObjectMapper();

    private final String jdbcUrl;
    private final String username;
    private final String password;

    public SqlKataVerifier(String jdbcUrl, String username, String password) {
        this.jdbcUrl = Objects.requireNonNull(jdbcUrl, "jdbcUrl");
        this.username = Objects.requireNonNull(username, "username");
        this.password = Objects.requireNonNull(password, "password");
    }

    public void assertKataMatches(String kataPath) {
        String kataResource = normalizeKataResource(kataPath);
        String solutionResource = toSolutionResource(kataResource);
        boolean useSolution = Boolean.getBoolean("useSolution");
        String candidateResource = useSolution ? solutionResource : kataResource;

        String candidateSql = readResource(candidateResource);
        String referenceSql = readResource(solutionResource);

        QueryResult candidate = execute(candidateSql, candidateResource);
        QueryResult reference = execute(referenceSql, solutionResource);

        String mismatch = compare(candidate, reference);
        if (mismatch != null) {
            fail(buildFailureMessage(
                    kataResource, candidateResource, solutionResource, useSolution,
                    candidate, reference, mismatch));
        }
    }

    /**
     * Проверяет DML-кату по состоянию базы после выполнения.
     *
     * <p>Нужно для команд без {@code RETURNING}, например {@code MERGE} в
     * PostgreSQL 16, который не поддерживает RETURNING. Кандидат и эталон
     * выполняются в отдельных транзакциях; затем в каждой транзакции
     * запускается один и тот же проверочный SELECT, результаты сравниваются,
     * после чего обе транзакции откатываются.</p>
     *
     * @param kataPath        путь к файлу каты (DML)
     * @param verificationPath путь к SELECT-запросу, читающему итоговое состояние
     */
    public void assertKataStateMatches(String kataPath, String verificationPath) {
        String kataResource = normalizeKataResource(kataPath);
        String solutionResource = toSolutionResource(kataResource);
        boolean useSolution = Boolean.getBoolean("useSolution");
        String candidateResource = useSolution ? solutionResource : kataResource;

        String candidateSql = readResource(candidateResource);
        String referenceSql = readResource(solutionResource);
        String verificationSql = readResource(verificationPath);

        QueryResult candidate = executeAndVerify(
                candidateSql, candidateResource, verificationSql, verificationPath);
        QueryResult reference = executeAndVerify(
                referenceSql, solutionResource, verificationSql, verificationPath);

        String mismatch = compare(candidate, reference);
        if (mismatch != null) {
            fail(buildStateFailureMessage(
                    kataResource, candidateResource, solutionResource,
                    verificationPath, useSolution, candidate, reference, mismatch));
        }
    }

    /**
     * Проверяет, что в плане запроса используется указанный индекс
     * узлом Index Scan, Index Only Scan или Bitmap Index Scan.
     */
    public void assertUsesIndex(String kataPath, String indexName) {
        PlanSnapshot plan = explainKata(kataPath);
        boolean found = plan.nodes().stream().anyMatch(node ->
                INDEX_NODE_TYPES.contains(node.nodeType())
                        && indexName.equals(node.indexName()));
        if (!found) {
            fail("""
                    Запрос не использует индекс %s.
                    Индекс должен встречаться в узле Index Scan, Index Only Scan
                    или Bitmap Index Scan.

                    Узлы плана:
                    %s
                    """.formatted(indexName, plan.render()));
        }
    }

    /**
     * Проверяет, что в плане запроса используется указанный индекс именно
     * узлом Index Only Scan (без обязательного чтения heap).
     */
    public void assertIndexOnlyScan(String kataPath, String indexName) {
        PlanSnapshot plan = explainKata(kataPath);
        boolean found = plan.nodes().stream().anyMatch(node ->
                "Index Only Scan".equals(node.nodeType())
                        && indexName.equals(node.indexName()));
        if (!found) {
            fail("""
                    Запрос не использует Index Only Scan по индексу %s.

                    Узлы плана:
                    %s
                    """.formatted(indexName, plan.render()));
        }
    }

    /**
     * Проверяет, что в плане нет Seq Scan по указанной relation.
     */
    public void assertNoSeqScan(String kataPath, String relationName) {
        PlanSnapshot plan = explainKata(kataPath);
        boolean hasSeqScan = plan.nodes().stream().anyMatch(node ->
                "Seq Scan".equals(node.nodeType())
                        && relationName.equals(node.relationName()));
        if (hasSeqScan) {
            fail("""
                    Найдён Seq Scan по большей таблице %s.

                    Узлы плана:
                    %s
                    """.formatted(relationName, plan.render()));
        }
    }

    /**
     * Проверяет конкурентный захват очереди двумя соединениями.
     *
     * <p>Первый воркер держит открытую транзакцию с захваченными строками,
     * второй воркер в это время обязан получить другую пачку. Без
     * {@code FOR UPDATE SKIP LOCKED} второй запрос заблокируется и упадёт
     * по query timeout. Обе транзакции в конце откатываются.</p>
     */
    public void assertSkipLocked(String kataPath, int batchSize) {
        String resource = resolveCandidateResource(kataPath);
        String sql = readResource(resource);
        Connection first = null;
        Connection second = null;
        ExecutorService executor = Executors.newSingleThreadExecutor();
        try {
            first = openConnection();
            second = openConnection();
            first.setAutoCommit(false);
            second.setAutoCommit(false);

            List<QueueClaim> firstBatch = executeQueueClaim(first, sql, 5);
            if (firstBatch.size() != batchSize) {
                fail("""
                        Первый воркер должен захватить %d задач, фактически захватил %d.
                        Ресурс: %s
                        SQL:
                        %s
                        """.formatted(batchSize, firstBatch.size(), resource, indentedSql(sql)));
            }
            validateClaimedStatuses(firstBatch, "первый", resource);

            Connection secondConnection = second;
            Future<List<QueueClaim>> future = executor.submit(
                    () -> executeQueueClaim(secondConnection, sql, 5));
            List<QueueClaim> secondBatch;
            try {
                secondBatch = future.get(10, TimeUnit.SECONDS);
            } catch (TimeoutException e) {
                future.cancel(true);
                fail("""
                        Второй воркер не завершился за 10 секунд.
                        Вероятно, запрос не использует FOR UPDATE SKIP LOCKED
                        и ждёт блокировку строк, захваченных первым воркером.
                        Ресурс: %s
                        """.formatted(resource));
                return; // unreachable
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                fail("Проверка SKIP LOCKED была прервана.");
                return; // unreachable
            } catch (ExecutionException e) {
                Throwable cause = e.getCause();
                String causeMessage = cause == null ? e.toString() : cause.getMessage();
                String hint = causeMessage != null
                        && (causeMessage.contains("timeout")
                            || causeMessage.contains("canceling statement"))
                        ? "\nВероятно, отсутствует FOR UPDATE SKIP LOCKED: второй воркер ждёт блокировку."
                        : "";
                fail("""
                        Второй воркер завершился ошибкой.%s
                        Причина: %s
                        Ресурс: %s
                        """.formatted(hint, causeMessage, resource));
                return; // unreachable
            } finally {
                executor.shutdownNow();
            }

            if (secondBatch.size() != batchSize) {
                fail("""
                        Второй воркер должен захватить %d задач, фактически захватил %d.
                        Первый воркер держал транзакцию открытой; проверь SKIP LOCKED.
                        """.formatted(batchSize, secondBatch.size()));
            }
            validateClaimedStatuses(secondBatch, "второй", resource);

            Set<Long> firstIds = new HashSet<>();
            for (QueueClaim claim : firstBatch) {
                firstIds.add(claim.taskId());
            }
            Set<Long> secondIds = new HashSet<>();
            for (QueueClaim claim : secondBatch) {
                secondIds.add(claim.taskId());
            }
            Set<Long> overlap = new HashSet<>(firstIds);
            overlap.retainAll(secondIds);
            if (!overlap.isEmpty()) {
                fail("""
                        Воркеры захватили пересекающиеся задачи: %s.
                        Захват пачки должен быть атомарным и не пересекаться.
                        Первый: %s
                        Второй: %s
                        """.formatted(overlap, firstIds, secondIds));
            }
        } catch (SQLException e) {
            fail("Ошибка при проверке SKIP LOCKED: " + e.getMessage());
        } finally {
            rollbackQuietly(first);
            rollbackQuietly(second);
            closeQuietly(first);
            closeQuietly(second);
            executor.shutdownNow();
        }
    }

    // -------------------------------------------------------------------------
    // Resource resolution
    // -------------------------------------------------------------------------

    private String normalizeKataResource(String rawPath) {
        if (rawPath == null || rawPath.isBlank()) {
            throw new IllegalArgumentException("Путь к SQL-кате не может быть пустым");
        }
        String path = rawPath.trim().replace('\\', '/');
        if (path.startsWith("classpath:")) {
            path = path.substring("classpath:".length());
        }
        while (path.startsWith("/")) {
            path = path.substring(1);
        }
        if (path.startsWith("solutions/")) {
            path = "katas/" + path.substring("solutions/".length());
        } else if (path.matches("^\\d{2}_[a-z]+/.*")) {
            path = "katas/" + path;
        }
        if (!path.startsWith("katas/") || path.contains("..")) {
            throw new IllegalArgumentException(
                    "Ожидался путь внутри katas/, получено: " + rawPath);
        }
        return path;
    }

    private String toSolutionResource(String kataResource) {
        return "solutions/" + kataResource.substring("katas/".length());
    }

    private String readResource(String resource) {
        ClassLoader loader = Thread.currentThread().getContextClassLoader();
        try (InputStream stream = loader.getResourceAsStream(resource)) {
            if (stream == null) {
                throw new IllegalArgumentException(
                        "Ресурс не найден в classpath: " + resource);
            }
            String sql = new String(stream.readAllBytes(), StandardCharsets.UTF_8);
            if (sql.startsWith("﻿")) {
                sql = sql.substring(1);
            }
            return sql.strip();
        } catch (IOException e) {
            throw new IllegalStateException("Не удалось прочитать ресурс: " + resource, e);
        }
    }

    // -------------------------------------------------------------------------
    // Execution (always rolled back)
    // -------------------------------------------------------------------------

    private QueryResult execute(String sql, String resource) {
        try (Connection connection = DriverManager.getConnection(jdbcUrl, username, password)) {
            connection.setAutoCommit(false);
            try {
                return executeInTransaction(connection, sql);
            } catch (SQLException e) {
                fail("""
                        Не удалось выполнить SQL.
                        Ресурс: %s
                        SQLState: %s
                        Ошибка PostgreSQL: %s

                        SQL:
                        %s
                        """.formatted(resource, e.getSQLState(), e.getMessage(), indentedSql(sql)));
                return null; // unreachable
            } finally {
                try {
                    connection.rollback();
                } catch (SQLException ignored) {
                    // Соединение всё равно будет закрыто.
                }
            }
        } catch (SQLException e) {
            fail("Не удалось подключиться к тестовой базе PostgreSQL: " + e.getMessage());
            return null; // unreachable
        }
    }

    private QueryResult executeAndVerify(
            String sql,
            String resource,
            String verificationSql,
            String verificationResource) {
        try (Connection connection = DriverManager.getConnection(jdbcUrl, username, password)) {
            connection.setAutoCommit(false);
            try {
                try {
                    // Собственный результат DML нам не нужен: истина — это
                    // состояние, которое прочитает verification SQL.
                    executeInTransaction(connection, sql);
                } catch (SQLException e) {
                    fail("""
                            Не удалось выполнить SQL кандидата/эталона.
                            Ресурс: %s
                            SQLState: %s
                            Ошибка PostgreSQL: %s

                            SQL:
                            %s
                            """.formatted(resource, e.getSQLState(), e.getMessage(),
                            indentedSql(sql)));
                }
                try {
                    return executeInTransaction(connection, verificationSql);
                } catch (SQLException e) {
                    fail("""
                            Не удалось выполнить проверку состояния.
                            Ресурс проверки: %s
                            SQLState: %s
                            Ошибка PostgreSQL: %s

                            SQL проверки:
                            %s
                            """.formatted(verificationResource, e.getSQLState(),
                            e.getMessage(), indentedSql(verificationSql)));
                    return null; // unreachable
                }
            } finally {
                try {
                    connection.rollback();
                } catch (SQLException ignored) {
                    // Соединение всё равно будет закрыто.
                }
            }
        } catch (SQLException e) {
            fail("Не удалось подключиться к тестовой базе PostgreSQL: " + e.getMessage());
            return null; // unreachable
        }
    }

    // -------------------------------------------------------------------------
    // EXPLAIN plan and queue concurrency helpers
    // -------------------------------------------------------------------------

    private String resolveCandidateResource(String rawPath) {
        String kataResource = normalizeKataResource(rawPath);
        return Boolean.getBoolean("useSolution")
                ? toSolutionResource(kataResource)
                : kataResource;
    }

    private Connection openConnection() throws SQLException {
        return DriverManager.getConnection(jdbcUrl, username, password);
    }

    private PlanSnapshot explainKata(String rawPath) {
        String resource = resolveCandidateResource(rawPath);
        String sql = readResource(resource);
        String explainSql = "EXPLAIN (FORMAT JSON) " + stripTrailingSemicolon(sql);

        try (Connection connection = openConnection()) {
            connection.setAutoCommit(false);
            try (Statement statement = connection.createStatement();
                 ResultSet resultSet = statement.executeQuery(explainSql)) {
                if (!resultSet.next()) {
                    fail("EXPLAIN вернул пустой результат для ресурса: " + resource);
                }
                String json = resultSet.getString(1);
                JsonNode root = JSON_MAPPER.readTree(json);
                JsonNode first = root.isArray() ? root.get(0) : root;
                JsonNode planNode = first == null ? null : first.get("Plan");
                if (planNode == null) {
                    fail("EXPLAIN JSON не содержит поля Plan. Ответ:\n" + json);
                }
                List<PlanNode> nodes = new ArrayList<>();
                collectPlanNodes(planNode, nodes);
                return new PlanSnapshot(List.copyOf(nodes));
            } catch (IOException e) {
                fail("Не удалось разобрать EXPLAIN JSON: " + e.getMessage());
                return null; // unreachable
            } finally {
                rollbackQuietly(connection);
            }
        } catch (SQLException e) {
            fail("""
                    Не удалось выполнить EXPLAIN для ресурса %s.
                    SQLState: %s
                    Ошибка: %s
                    """.formatted(resource, e.getSQLState(), e.getMessage()));
            return null; // unreachable
        }
    }

    private void collectPlanNodes(JsonNode node, List<PlanNode> result) {
        if (node == null) {
            return;
        }
        String nodeType = textOrNull(node.get("Node Type"));
        String relationName = textOrNull(node.get("Relation Name"));
        String indexName = textOrNull(node.get("Index Name"));
        if (nodeType != null) {
            result.add(new PlanNode(nodeType, relationName, indexName));
        }
        JsonNode children = node.get("Plans");
        if (children != null && children.isArray()) {
            for (JsonNode child : children) {
                collectPlanNodes(child, result);
            }
        }
    }

    private List<QueueClaim> executeQueueClaim(
            Connection connection, String sql, int timeoutSeconds) throws SQLException {
        try (Statement statement = connection.createStatement()) {
            statement.setQueryTimeout(timeoutSeconds);
            boolean hasResultSet = statement.execute(sql);
            if (!hasResultSet) {
                throw new SQLException(
                        "Запрос захвата должен возвращать ResultSet через RETURNING");
            }
            try (ResultSet resultSet = statement.getResultSet()) {
                if (resultSet.getMetaData().getColumnCount() < 2) {
                    throw new SQLException(
                            "Ожидались как минимум колонки task_id и status в RETURNING");
                }
                List<QueueClaim> claims = new ArrayList<>();
                while (resultSet.next()) {
                    claims.add(new QueueClaim(
                            resultSet.getLong(1),
                            resultSet.getString(2)));
                }
                return claims;
            }
        }
    }

    private void validateClaimedStatuses(
            List<QueueClaim> claims, String workerLabel, String resource) {
        for (QueueClaim claim : claims) {
            if (!"PROCESSING".equals(claim.status())) {
                fail("""
                        %s воркер вернул задачу %d со статусом %s, ожидался PROCESSING.
                        Ресурс: %s
                        """.formatted(workerLabel, claim.taskId(), claim.status(), resource));
            }
        }
    }

    private void rollbackQuietly(Connection connection) {
        if (connection == null) {
            return;
        }
        try {
            connection.rollback();
        } catch (SQLException ignored) {
            // Соединение закрывается дальше.
        }
    }

    private void closeQuietly(Connection connection) {
        if (connection == null) {
            return;
        }
        try {
            connection.close();
        } catch (SQLException ignored) {
            // Ничего не остаётся сделать.
        }
    }

    private static String stripTrailingSemicolon(String sql) {
        String trimmed = sql.strip();
        while (trimmed.endsWith(";")) {
            trimmed = trimmed.substring(0, trimmed.length() - 1).stripTrailing();
        }
        return trimmed;
    }

    private static String textOrNull(JsonNode node) {
        return node == null || node.isNull() ? null : node.asText();
    }

    private static String renderPlan(List<PlanNode> nodes) {
        if (nodes.isEmpty()) {
            return "  <пустой план>";
        }
        StringBuilder result = new StringBuilder();
        for (PlanNode node : nodes) {
            result.append("  - ").append(node.nodeType());
            if (node.relationName() != null) {
                result.append(" [relation=").append(node.relationName()).append(']');
            }
            if (node.indexName() != null) {
                result.append(" [index=").append(node.indexName()).append(']');
            }
            result.append('\n');
        }
        return result.toString();
    }

    private QueryResult executeInTransaction(Connection connection, String sql)
            throws SQLException {
        try (Statement statement = connection.createStatement()) {
            boolean hasResultSet = statement.execute(sql);
            if (!hasResultSet) {
                return QueryResult.withoutRows(statement.getUpdateCount());
            }
            try (ResultSet resultSet = statement.getResultSet()) {
                return readResultSet(resultSet);
            }
        }
    }

    private QueryResult readResultSet(ResultSet resultSet) throws SQLException {
        ResultSetMetaData meta = resultSet.getMetaData();
        int columnCount = meta.getColumnCount();
        List<Column> columns = new ArrayList<>(columnCount);
        for (int i = 1; i <= columnCount; i++) {
            columns.add(new Column(
                    meta.getColumnLabel(i),
                    canonicalTypeName(meta.getColumnTypeName(i))));
        }

        List<List<Object>> rows = new ArrayList<>();
        while (resultSet.next()) {
            List<Object> row = new ArrayList<>(columnCount);
            for (int i = 1; i <= columnCount; i++) {
                row.add(normalizeValue(resultSet.getObject(i)));
            }
            // List.copyOf запрещает NULL-элементы, а NULL — легальное
            // значение SQL-результата, поэтому используем unmodifiable view.
            rows.add(Collections.unmodifiableList(new ArrayList<>(row)));
        }
        return new QueryResult(List.copyOf(columns), List.copyOf(rows), true, -1);
    }

    /**
     * PostgreSQL JDBC может назвать тип identity-колонки {@code serial},
     * хотя физически это {@code int4}. Приводим псевдонимы к базовым типам,
     * чтобы обёртка подзапроса или CTE не давала ложное расхождение типов.
     */
    private String canonicalTypeName(String typeName) {
        return switch (typeName.toLowerCase(Locale.ROOT)) {
            case "serial" -> "int4";
            case "bigserial" -> "int8";
            case "smallserial" -> "int2";
            default -> typeName;
        };
    }

    private Object normalizeValue(Object value) throws SQLException {
        if (value == null) {
            return null;
        }
        if (value instanceof Array sqlArray) {
            Object raw = sqlArray.getArray();
            if (raw == null) {
                return null;
            }
            int length = java.lang.reflect.Array.getLength(raw);
            List<Object> normalized = new ArrayList<>(length);
            for (int i = 0; i < length; i++) {
                normalized.add(normalizeValue(java.lang.reflect.Array.get(raw, i)));
            }
            return Collections.unmodifiableList(normalized);
        }
        if (value instanceof PGobject pgObject) {
            // jsonb/json и прочие extension-типы PostgreSQL. Тип проверяет
            // metadata, а значение сравниваем в каноническом текстовом виде.
            return pgObject.getValue();
        }
        if (value instanceof BigDecimal decimal) {
            return decimal;
        }
        if (value instanceof Timestamp || value instanceof java.sql.Date
                || value instanceof java.sql.Time || value instanceof byte[]
                || value instanceof Boolean || value instanceof Number
                || value instanceof CharSequence) {
            return value;
        }
        // Остальные JDBC-типы (UUID, OffsetDateTime, LocalDate и т. п.) имеют
        // корректный equals; оставляем их как есть.
        return value;
    }

    // -------------------------------------------------------------------------
    // Comparison
    // -------------------------------------------------------------------------

    private String compare(QueryResult candidate, QueryResult reference) {
        if (candidate.hasResultSet != reference.hasResultSet) {
            if (reference.hasResultSet) {
                return "Эталон вернул ResultSet, а кандидат — только счётчик изменённых строк.";
            }
            return "Кандидат вернул ResultSet, а эталон — только счётчик изменённых строк.";
        }

        if (!reference.hasResultSet) {
            if (candidate.updateCount != reference.updateCount) {
                return "Не совпадает число изменённых строк: эталон=%d, кандидат=%d."
                        .formatted(reference.updateCount, candidate.updateCount);
            }
            return null;
        }

        if (candidate.columns.size() != reference.columns.size()) {
            return "Не совпадает число колонок: эталон=%d, кандидат=%d."
                    .formatted(reference.columns.size(), candidate.columns.size());
        }

        for (int i = 0; i < reference.columns.size(); i++) {
            Column expected = reference.columns.get(i);
            Column actual = candidate.columns.get(i);
            if (!expected.label.equals(actual.label)) {
                return "Колонка #%d: ожидалось имя %s, получено %s."
                        .formatted(i + 1, quote(expected.label), quote(actual.label));
            }
            if (!expected.typeName.equalsIgnoreCase(actual.typeName)) {
                return "Колонка #%d (%s): ожидался тип %s, получен %s."
                        .formatted(i + 1, expected.label, expected.typeName, actual.typeName);
            }
        }

        if (candidate.rows.size() != reference.rows.size()) {
            return "Не совпадает число строк: эталон=%d, кандидат=%d."
                    .formatted(reference.rows.size(), candidate.rows.size());
        }

        for (int row = 0; row < reference.rows.size(); row++) {
            List<Object> expectedRow = reference.rows.get(row);
            List<Object> actualRow = candidate.rows.get(row);
            for (int col = 0; col < expectedRow.size(); col++) {
                Object expectedValue = expectedRow.get(col);
                Object actualValue = actualRow.get(col);
                if (!valuesEqual(expectedValue, actualValue)) {
                    return "Строка %d, колонка %d (%s).%n  эталон:   %s%n  кандидат: %s"
                            .formatted(row + 1, col + 1, reference.columns.get(col).label,
                                    display(expectedValue), display(actualValue));
                }
            }
        }
        return null;
    }

    private boolean valuesEqual(Object expected, Object actual) {
        if (expected == null || actual == null) {
            return expected == actual;
        }
        if (expected instanceof BigDecimal expectedDecimal
                && actual instanceof BigDecimal actualDecimal) {
            return expectedDecimal.compareTo(actualDecimal) == 0;
        }
        if (expected instanceof byte[] expectedBytes && actual instanceof byte[] actualBytes) {
            return Arrays.equals(expectedBytes, actualBytes);
        }
        if (expected instanceof List<?> expectedList && actual instanceof List<?> actualList) {
            if (expectedList.size() != actualList.size()) {
                return false;
            }
            for (int i = 0; i < expectedList.size(); i++) {
                if (!valuesEqual(expectedList.get(i), actualList.get(i))) {
                    return false;
                }
            }
            return true;
        }
        return Objects.equals(expected, actual);
    }

    // -------------------------------------------------------------------------
    // Human-readable failure
    // -------------------------------------------------------------------------

    private String buildFailureMessage(
            String kataResource,
            String candidateResource,
            String solutionResource,
            boolean useSolution,
            QueryResult candidate,
            QueryResult reference,
            String mismatch) {
        StringBuilder message = new StringBuilder(4_096);
        message.append("SQL-ката не прошла проверку\n")
                .append("Ката:      ").append(kataResource).append('\n')
                .append("Кандидат:  ").append(candidateResource).append('\n')
                .append("Эталон:    ").append(solutionResource).append('\n')
                .append("Режим:     ").append(useSolution
                        ? "проверка эталона (-DuseSolution=true)"
                        : "решение пользователя").append("\n\n")
                .append("Причина: ").append(mismatch).append("\n\n")
                .append("Колонки эталона:\n  ").append(describeColumns(reference)).append('\n')
                .append("Колонки кандидата:\n  ").append(describeColumns(candidate)).append('\n')
                .append("\nЭталонные строки")
                .append(rowCountSuffix(reference)).append(":\n")
                .append(renderRows(reference)).append('\n')
                .append("Строки кандидата")
                .append(rowCountSuffix(candidate)).append(":\n")
                .append(renderRows(candidate)).append('\n');
        return message.toString();
    }

    private String buildStateFailureMessage(
            String kataResource,
            String candidateResource,
            String solutionResource,
            String verificationResource,
            boolean useSolution,
            QueryResult candidate,
            QueryResult reference,
            String mismatch) {
        StringBuilder message = new StringBuilder(4_096);
        message.append("SQL-ката не прошла проверку состояния\n")
                .append("Ката:         ").append(kataResource).append('\n')
                .append("Кандидат:     ").append(candidateResource).append('\n')
                .append("Эталон:       ").append(solutionResource).append('\n')
                .append("Проверка:     ").append(verificationResource).append('\n')
                .append("Режим:        ").append(useSolution
                        ? "проверка эталона (-DuseSolution=true)"
                        : "решение пользователя").append("\n\n")
                .append("Причина: ").append(mismatch).append("\n\n")
                .append("Сравнивается SELECT-снимок базы после DML.\n\n")
                .append("Колонки эталона:\n  ").append(describeColumns(reference)).append('\n')
                .append("Колонки кандидата:\n  ").append(describeColumns(candidate)).append('\n')
                .append("\nЭталонное состояние")
                .append(rowCountSuffix(reference)).append(":\n")
                .append(renderRows(reference)).append('\n')
                .append("Состояние кандидата")
                .append(rowCountSuffix(candidate)).append(":\n")
                .append(renderRows(candidate)).append('\n');
        return message.toString();
    }

    private String describeColumns(QueryResult result) {
        if (!result.hasResultSet) {
            return "<нет ResultSet, updateCount=" + result.updateCount + ">";
        }
        if (result.columns.isEmpty()) {
            return "<нет колонок>";
        }
        List<String> columns = new ArrayList<>(result.columns.size());
        for (Column column : result.columns) {
            columns.add(column.label + ":" + column.typeName);
        }
        return String.join(", ", columns);
    }

    private String rowCountSuffix(QueryResult result) {
        if (!result.hasResultSet) {
            return " (нет ResultSet)";
        }
        return result.rows.size() > MAX_ROWS_IN_DIFF
                ? " (первые %d из %d)".formatted(MAX_ROWS_IN_DIFF, result.rows.size())
                : " (%d)".formatted(result.rows.size());
    }

    private String renderRows(QueryResult result) {
        if (!result.hasResultSet) {
            return "  <ResultSet отсутствует>";
        }
        if (result.rows.isEmpty()) {
            return "  <пусто>";
        }
        StringBuilder out = new StringBuilder();
        int limit = Math.min(result.rows.size(), MAX_ROWS_IN_DIFF);
        for (int i = 0; i < limit; i++) {
            out.append("  [").append(i + 1).append("] ");
            List<Object> row = result.rows.get(i);
            List<String> cells = new ArrayList<>(row.size());
            for (int col = 0; col < row.size(); col++) {
                cells.add(result.columns.get(col).label + "=" + display(row.get(col)));
            }
            out.append(String.join(" | ", cells)).append('\n');
        }
        if (result.rows.size() > limit) {
            out.append("  ... ещё ").append(result.rows.size() - limit).append(" строк\n");
        }
        return out.toString();
    }

    private String display(Object value) {
        if (value == null) {
            return "NULL";
        }
        if (value instanceof String string) {
            return "'" + string.replace("\\", "\\\\")
                    .replace("\n", "\\n")
                    .replace("'", "''") + "'";
        }
        if (value instanceof BigDecimal decimal) {
            return decimal.toPlainString();
        }
        if (value instanceof byte[] bytes) {
            StringBuilder hex = new StringBuilder("0x");
            for (byte b : bytes) {
                hex.append("%02x".formatted(b));
            }
            return hex.toString();
        }
        if (value instanceof List<?> list) {
            List<String> items = new ArrayList<>(list.size());
            for (Object item : list) {
                items.add(display(item));
            }
            return "[" + String.join(", ", items) + "]";
        }
        return value.toString();
    }

    private static String quote(String value) {
        return "'" + value + "'";
    }

    private static String indentedSql(String sql) {
        return sql.lines()
                .map(line -> "    " + line)
                .reduce((left, right) -> left + "\n" + right)
                .orElse("    <пустой SQL>");
    }

    // -------------------------------------------------------------------------
    // Value objects
    // -------------------------------------------------------------------------

    private record Column(String label, String typeName) {
    }

    private record QueryResult(
            List<Column> columns,
            List<List<Object>> rows,
            boolean hasResultSet,
            int updateCount) {

        static QueryResult withoutRows(int updateCount) {
            return new QueryResult(List.of(), List.of(), false, updateCount);
        }
    }

    private record PlanNode(String nodeType, String relationName, String indexName) {
    }

    private record PlanSnapshot(List<PlanNode> nodes) {
        String render() {
            return renderPlan(nodes);
        }
    }

    private record QueueClaim(long taskId, String status) {
    }
}
