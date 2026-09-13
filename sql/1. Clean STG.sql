-- LIMPIEZA, TRANSFORMACIÓN Y CONTROL DE CALIDAD
CREATE OR REPLACE TABLE `dwh-bdb.bdb_dwh.stg_transactions_clean` AS
SELECT

  -- validacion de la Identificación
  CASE
    WHEN TRIM(`tipo de identificación`) IN ('CC', 'CE', 'TI', 'PAS')
      THEN TRIM(`tipo de identificación`)
    ELSE NULL
  END AS tipo_identificacion,

  SAFE_CAST(`número de identificación` AS STRING)
    AS numero_identificacion,

  SAFE_CAST(`número de cuenta` AS STRING)
    AS numero_cuenta,

  -- Datos del cliente
  TRIM(`nombres`) AS nombres,

  TRIM(`tipo transacción`) AS tipo_transaccion,

  -- Validacion del monto válido y no negativo
  CASE
    WHEN SAFE_CAST(`monto transacción` AS NUMERIC) >= 0
      THEN SAFE_CAST(`monto transacción` AS NUMERIC)
    ELSE NULL
  END AS monto_transaccion,

  TRIM(`tipo de producto`) AS tipo_producto,

  TRIM(`ciudad`) AS ciudad,

  -- Fecha en formato TIMESTAMP para que tod sea un formato uniforme y compatible con la dimensión de fecha
  CASE
    WHEN REGEXP_CONTAINS(`fecha-hora`, r'^\d{10}$')
      THEN TIMESTAMP_SECONDS(
        SAFE_CAST(`fecha-hora` AS INT64)
      )
    ELSE SAFE.PARSE_TIMESTAMP(
      '%Y-%m-%d %H:%M:%S',
      `fecha-hora`
    )
  END AS fecha_hora,

  `fecha de nacimiento` AS fecha_nacimiento,

  TRIM(`dirección del cliente`) AS direccion_cliente,

  SAFE_CAST(`teléfono del cliente` AS STRING)
    AS telefono_cliente,

  LOWER(TRIM(`correo del cliente`)) AS correo_cliente,
  -- Riesgo
  TRIM(`reporte centrales de riesgo`) AS reporte_riesgo,

  CASE
    WHEN SAFE_CAST(
      `monto reporte de central de riesgo` AS NUMERIC
    ) >= 0
      THEN SAFE_CAST(
        `monto reporte de central de riesgo` AS NUMERIC
      )
    ELSE NULL
  END AS monto_riesgo,

  CASE
    WHEN SAFE_CAST(
      REGEXP_EXTRACT(
        LOWER(TRIM(`tiempo en mora del reporte de riesgo`)),
        r'(\d+)'
      ) AS INT64
    ) >= 0
      THEN SAFE_CAST(
        REGEXP_EXTRACT(
          LOWER(TRIM(`tiempo en mora del reporte de riesgo`)),
          r'(\d+)'
        ) AS INT64
      )
    ELSE NULL
  END AS tiempo_mora_dias,

  -- Trazabilidad
  CURRENT_TIMESTAMP() AS processing_timestamp

FROM `dwh-bdb.bdb_dwh.stg_transactions`;