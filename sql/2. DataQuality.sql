create or replace table `dwh-bdb.bdb_dwh.dq_results` (
  execution_id STRING,
  rule_name STRING,
  description STRING,
  severity STRING,
  checked_rows INT64,
  failed_rows INT64,
  status STRING,
  execution_time TIMESTAMP
);

DECLARE execution_id STRING DEFAULT GENERATE_UUID();

INSERT INTO `dwh-bdb.bdb_dwh.dq_results`
(
  execution_id,
  rule_name,
  description,
  severity,
  checked_rows,
  failed_rows,
  status,
  execution_time
)

WITH base AS (
  SELECT
    COUNT(*) AS total
  FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
),

reglas AS (

  -- DQ_001: Identificación completa
  SELECT
    'DQ_001' AS rule_name,
    'Validar que tipo y número de identificación estén informados' AS description,
    'CRITICAL' AS severity,
    b.total AS checked_rows,
    (
      SELECT COUNT(*)
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
      WHERE tipo_identificacion IS NULL
         OR numero_identificacion IS NULL
         OR TRIM(numero_identificacion) = ''
    ) AS failed_rows
  FROM base b

  UNION ALL

  -- DQ_002: Tipo de identificación válido
  SELECT
    'DQ_002',
    'Validar catálogo de tipos de identificación',
    'CRITICAL',
    b.total,
    (
      SELECT COUNT(*)
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
      WHERE tipo_identificacion IS NULL
         OR tipo_identificacion NOT IN ('CC', 'CE', 'TI', 'PAS')
    )
  FROM base b

  UNION ALL

  -- DQ_003: Cuenta completa
  SELECT
    'DQ_003',
    'Validar que el número de cuenta esté informado',
    'CRITICAL',
    b.total,
    (
      SELECT COUNT(*)
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
      WHERE numero_cuenta IS NULL
         OR TRIM(numero_cuenta) = ''
    )
  FROM base b

  UNION ALL

  -- DQ_004: Monto válido
  SELECT
    'DQ_004',
    'Validar que el monto de transacción sea mayor que cero',
    'CRITICAL',
    b.total,
    (
      SELECT COUNT(*)
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
      WHERE monto_transaccion IS NULL
         OR monto_transaccion <= 0
    )
  FROM base b

  UNION ALL

  -- DQ_005: Fecha válida
  SELECT
    'DQ_005',
    'Validar que la fecha y hora de la transacción sean válidas',
    'CRITICAL',
    b.total,
    (
      SELECT COUNT(*)
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
      WHERE fecha_hora IS NULL
    )
  FROM base b

  UNION ALL

  -- DQ_006: Tipo de transacción
  SELECT
    'DQ_006',
    'Validar que el tipo de transacción esté informado',
    'CRITICAL',
    b.total,
    (
      SELECT COUNT(*)
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
      WHERE tipo_transaccion IS NULL
         OR TRIM(tipo_transaccion) = ''
    )
  FROM base b

  UNION ALL

  -- DQ_007: Producto
  SELECT
    'DQ_007',
    'Validar que el tipo de producto esté informado',
    'CRITICAL',
    b.total,
    (
      SELECT COUNT(*)
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
      WHERE tipo_producto IS NULL
         OR TRIM(tipo_producto) = ''
    )
  FROM base b

  UNION ALL

  -- DQ_008: Riesgo
  SELECT
    'DQ_008',
    'Validar consistencia de la información de riesgo',
    'CRITICAL',
    b.total,
    (
      SELECT COUNT(*)
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
      WHERE
        (
          reporte_riesgo = 'Sí'
          AND monto_riesgo IS NULL
        )
        OR
        (
          reporte_riesgo = 'No'
          AND (
            monto_riesgo IS NOT NULL
            OR tiempo_mora_dias IS NOT NULL
          )
        )
    )
  FROM base b

  UNION ALL

  -- DQ_009: Unicidad
  SELECT
    'DQ_009',
    'Validar que no existan transacciones duplicadas',
    'CRITICAL',
    b.total,
    (
      SELECT COUNT(*)
      FROM (
        SELECT
          numero_cuenta,
          fecha_hora,
          monto_transaccion,
          tipo_transaccion,
          tipo_producto
        FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
        GROUP BY
          numero_cuenta,
          fecha_hora,
          monto_transaccion,
          tipo_transaccion,
          tipo_producto
        HAVING COUNT(*) > 1
      )
    )
  FROM base b

  UNION ALL

  -- DQ_010: Correo
  SELECT
    'DQ_010',
    'Validar formato del correo electrónico cuando esté informado',
    'WARNING',
    b.total,
    (
      SELECT COUNT(*)
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
      WHERE correo_cliente IS NOT NULL
        AND TRIM(correo_cliente) != ''
        AND NOT REGEXP_CONTAINS(
          correo_cliente,
          r'^[^@\s]+@[^@\s]+\.[^@\s]+$'
        )
    )
  FROM base b
)

SELECT
  execution_id,
  rule_name,
  description,
  severity,
  checked_rows,
  failed_rows,

  CASE
    WHEN failed_rows = 0 THEN 'PASS'
    WHEN severity = 'WARNING' THEN 'WARNING'
    ELSE 'FAIL'
  END AS status,

  CURRENT_TIMESTAMP()
FROM reglas;