USE vclub;
SET @tiempoini=CURRENT_TIMESTAMP();
SELECT '=== Verificacion de carga vclub (MySQL) ===' AS info;

SET @schema_name = DATABASE();

DROP TEMPORARY TABLE IF EXISTS expected_tables;
CREATE TEMPORARY TABLE expected_tables (
    table_name VARCHAR(64) PRIMARY KEY,
    expected_rows BIGINT NOT NULL
);

INSERT INTO expected_tables (table_name, expected_rows)
VALUES
    ('actor', 200),
    ('pais', 109),
    ('ciudad', 600),
    ('direccion', 603),
    ('categoria', 16),
    ('idioma', 6),
    ('pelicula', 1000),
    ('tienda', 2),
    ('personal', 2),
    ('cliente', 599),
    ('inventario', 4581),
    ('alquiler', 16044),
    ('pago', 16044),
    ('pelicula_actor', 5462),
    ('pelicula_categoria', 1000);

SET @expected_tables_count = (SELECT COUNT(*) FROM expected_tables);
SET @actual_tables_count = (
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = @schema_name
      AND table_type = 'BASE TABLE'
);

SELECT
    'Cantidad de tablas esperadas' AS check_name,
    CAST(@expected_tables_count AS CHAR) AS expected_value,
    CAST(@actual_tables_count AS CHAR) AS actual_value,
    CASE WHEN @actual_tables_count = @expected_tables_count THEN 'PASS' ELSE 'FAIL' END AS status;

SELECT
    'Tablas faltantes' AS check_name,
    e.table_name AS expected_value,
    NULL AS actual_value,
    'FAIL' AS status
FROM expected_tables e
LEFT JOIN information_schema.tables t
    ON t.table_schema = @schema_name
   AND t.table_name = e.table_name
   AND t.table_type = 'BASE TABLE'
WHERE t.table_name IS NULL;

DROP TEMPORARY TABLE IF EXISTS actual_counts;
CREATE TEMPORARY TABLE actual_counts (
    table_name VARCHAR(64) PRIMARY KEY,
    actual_rows BIGINT NULL
);

DROP PROCEDURE IF EXISTS fill_actual_counts;
DELIMITER $$
CREATE PROCEDURE fill_actual_counts()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_table VARCHAR(64);
    DECLARE v_exists INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT table_name FROM expected_tables;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_table;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SELECT COUNT(*)
        INTO v_exists
        FROM information_schema.tables
        WHERE table_schema = @schema_name
          AND table_name = v_table
          AND table_type = 'BASE TABLE';

        IF v_exists = 1 THEN
            SET @dyn_sql = CONCAT(
                'SELECT COUNT(*) INTO @row_count FROM `',
                REPLACE(v_table, '`', '``'),
                '`'
            );

            PREPARE stmt FROM @dyn_sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            INSERT INTO actual_counts (table_name, actual_rows)
            VALUES (v_table, @row_count);
        ELSE
            INSERT INTO actual_counts (table_name, actual_rows)
            VALUES (v_table, NULL);
        END IF;
    END LOOP;

    CLOSE cur;
END$$
DELIMITER ;

CALL fill_actual_counts();
DROP PROCEDURE fill_actual_counts;

SELECT
    'Conteo por tabla' AS check_name,
    e.table_name,
    e.expected_rows,
    a.actual_rows,
    CASE WHEN a.actual_rows = e.expected_rows THEN 'PASS' ELSE 'FAIL' END AS status
FROM expected_tables e
LEFT JOIN actual_counts a
    ON a.table_name = e.table_name
ORDER BY e.table_name;

SET @expected_fk_count = 22;
SET @actual_fk_count = (
    SELECT COUNT(*)
    FROM information_schema.referential_constraints rc
    WHERE rc.constraint_schema = @schema_name
);

SELECT
    'Cantidad de foreign keys esperadas' AS check_name,
    CAST(@expected_fk_count AS CHAR) AS expected_value,
    CAST(@actual_fk_count AS CHAR) AS actual_value,
    CASE WHEN @actual_fk_count = @expected_fk_count THEN 'PASS' ELSE 'FAIL' END AS status;

SELECT
    'Foreign key checks habilitado' AS check_name,
    '1' AS expected_value,
    CAST(@@FOREIGN_KEY_CHECKS AS CHAR) AS actual_value,
    CASE WHEN @@FOREIGN_KEY_CHECKS = 1 THEN 'PASS' ELSE 'FAIL' END AS status;

DROP TEMPORARY TABLE IF EXISTS constraint_violations;
CREATE TEMPORARY TABLE constraint_violations (
    constraint_name VARCHAR(128) PRIMARY KEY,
    violation_count BIGINT NOT NULL
);

INSERT INTO constraint_violations (constraint_name, violation_count)
SELECT 'fk_ciudad_pais', COUNT(*)
FROM ciudad c
LEFT JOIN pais p ON p.id_pais = c.id_pais
WHERE p.id_pais IS NULL
UNION ALL
SELECT 'fk_direccion_ciudad', COUNT(*)
FROM direccion d
LEFT JOIN ciudad c ON c.id_ciudad = d.id_ciudad
WHERE c.id_ciudad IS NULL
UNION ALL
SELECT 'fk_pelicula_idioma', COUNT(*)
FROM pelicula p
LEFT JOIN idioma i ON i.id_idioma = p.id_idioma
WHERE i.id_idioma IS NULL
UNION ALL
SELECT 'fk_pelicula_idioma_original', COUNT(*)
FROM pelicula p
LEFT JOIN idioma i ON i.id_idioma = p.id_idioma_original
WHERE p.id_idioma_original IS NOT NULL AND i.id_idioma IS NULL
UNION ALL
SELECT 'fk_tienda_direccion', COUNT(*)
FROM tienda t
LEFT JOIN direccion d ON d.id_direccion = t.id_direccion
WHERE d.id_direccion IS NULL
UNION ALL
SELECT 'fk_tienda_personal', COUNT(*)
FROM tienda t
LEFT JOIN personal p ON p.id_personal = t.id_personal_gerente
WHERE t.id_personal_gerente IS NOT NULL AND p.id_personal IS NULL
UNION ALL
SELECT 'fk_personal_direccion', COUNT(*)
FROM personal p
LEFT JOIN direccion d ON d.id_direccion = p.id_direccion
WHERE d.id_direccion IS NULL
UNION ALL
SELECT 'fk_personal_tienda', COUNT(*)
FROM personal p
LEFT JOIN tienda t ON t.id_tienda = p.id_tienda
WHERE t.id_tienda IS NULL
UNION ALL
SELECT 'fk_cliente_direccion', COUNT(*)
FROM cliente c
LEFT JOIN direccion d ON d.id_direccion = c.id_direccion
WHERE d.id_direccion IS NULL
UNION ALL
SELECT 'fk_cliente_tienda', COUNT(*)
FROM cliente c
LEFT JOIN tienda t ON t.id_tienda = c.id_tienda
WHERE t.id_tienda IS NULL
UNION ALL
SELECT 'fk_inventario_pelicula', COUNT(*)
FROM inventario i
LEFT JOIN pelicula p ON p.id_pelicula = i.id_pelicula
WHERE p.id_pelicula IS NULL
UNION ALL
SELECT 'fk_inventario_tienda', COUNT(*)
FROM inventario i
LEFT JOIN tienda t ON t.id_tienda = i.id_tienda
WHERE t.id_tienda IS NULL
UNION ALL
SELECT 'fk_alquiler_inventario', COUNT(*)
FROM alquiler a
LEFT JOIN inventario i ON i.id_inventario = a.id_inventario
WHERE i.id_inventario IS NULL
UNION ALL
SELECT 'fk_alquiler_cliente', COUNT(*)
FROM alquiler a
LEFT JOIN cliente c ON c.id_cliente = a.id_cliente
WHERE c.id_cliente IS NULL
UNION ALL
SELECT 'fk_alquiler_personal', COUNT(*)
FROM alquiler a
LEFT JOIN personal p ON p.id_personal = a.id_personal
WHERE p.id_personal IS NULL
UNION ALL
SELECT 'fk_pago_alquiler', COUNT(*)
FROM pago p
LEFT JOIN alquiler a ON a.id_alquiler = p.id_alquiler
WHERE p.id_alquiler IS NOT NULL AND a.id_alquiler IS NULL
UNION ALL
SELECT 'fk_pago_cliente', COUNT(*)
FROM pago p
LEFT JOIN cliente c ON c.id_cliente = p.id_cliente
WHERE c.id_cliente IS NULL
UNION ALL
SELECT 'fk_pago_personal', COUNT(*)
FROM pago p
LEFT JOIN personal s ON s.id_personal = p.id_personal
WHERE s.id_personal IS NULL
UNION ALL
SELECT 'fk_pelicula_actor_actor', COUNT(*)
FROM pelicula_actor pa
LEFT JOIN actor a ON a.id_actor = pa.id_actor
WHERE a.id_actor IS NULL
UNION ALL
SELECT 'fk_pelicula_actor_pelicula', COUNT(*)
FROM pelicula_actor pa
LEFT JOIN pelicula p ON p.id_pelicula = pa.id_pelicula
WHERE p.id_pelicula IS NULL
UNION ALL
SELECT 'fk_pelicula_categoria_pelicula', COUNT(*)
FROM pelicula_categoria pc
LEFT JOIN pelicula p ON p.id_pelicula = pc.id_pelicula
WHERE p.id_pelicula IS NULL
UNION ALL
SELECT 'fk_pelicula_categoria_categoria', COUNT(*)
FROM pelicula_categoria pc
LEFT JOIN categoria c ON c.id_categoria = pc.id_categoria
WHERE c.id_categoria IS NULL;

SELECT
    'Violaciones de constraints' AS check_name,
    '0' AS expected_value,
    CAST(SUM(violation_count) AS CHAR) AS actual_value,
    CASE WHEN SUM(violation_count) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM constraint_violations;

SELECT
    constraint_name,
    violation_count
FROM constraint_violations
WHERE violation_count > 0
ORDER BY constraint_name;

SET @has_bad_counts = (
    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM expected_tables e
    LEFT JOIN actual_counts a ON a.table_name = e.table_name
    WHERE a.actual_rows IS NULL OR a.actual_rows <> e.expected_rows
);

SET @has_missing_tables = (
    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM expected_tables e
    LEFT JOIN information_schema.tables t
        ON t.table_schema = @schema_name
       AND t.table_name = e.table_name
       AND t.table_type = 'BASE TABLE'
    WHERE t.table_name IS NULL
);

SET @has_fk_count_mismatch = CASE WHEN @actual_fk_count <> @expected_fk_count THEN 1 ELSE 0 END;
SET @has_fk_checks_disabled = CASE WHEN @@FOREIGN_KEY_CHECKS <> 1 THEN 1 ELSE 0 END;
SET @has_constraint_violations = (
    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM constraint_violations
    WHERE violation_count > 0
);

SELECT
    CASE
        WHEN @has_bad_counts = 1 THEN 'FAIL'
        WHEN @has_missing_tables = 1 THEN 'FAIL'
        WHEN @has_fk_count_mismatch = 1 THEN 'FAIL'
        WHEN @has_fk_checks_disabled = 1 THEN 'FAIL'
        WHEN @has_constraint_violations = 1 THEN 'FAIL'
        ELSE 'PASS'
    END AS resultado_final,
    TIMESTAMPDIFF(MICROSECOND,@tiempoini,CURRENT_TIMESTAMP())/1000 AS tiempo_ejecucion,
    @@server_uuid AS uuid_verificacion,
    @@hostname AS servidor,
    @@version AS version_mysql,
    @@version_compile_os AS version_compile_os;

DROP TEMPORARY TABLE IF EXISTS actual_counts;
DROP TEMPORARY TABLE IF EXISTS constraint_violations;
DROP TEMPORARY TABLE IF EXISTS expected_tables;
