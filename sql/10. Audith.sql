-- ============================================================
-- AUDITORÍA DEL PIPELINE
-- ============================================================

CREATE TABLE IF NOT EXISTS `dwh-bdb.bdb_dwh.audit_pipeline`
(
  execution_id STRING,
  pipeline_name STRING,
  source_file STRING,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  rows_read INT64,
  rows_processed INT64,
  rows_rejected INT64,
  status STRING,
  error_message STRING
);


-- ============================================================
-- EJEMPLO DE REGISTRO DE EJECUCIÓN
-- ============================================================

INSERT INTO `dwh-bdb.bdb_dwh.audit_pipeline`
(
  execution_id,
  pipeline_name,
  source_file,
  start_time,
  end_time,
  rows_read,
  rows_processed,
  rows_rejected,
  status,
  error_message
)
VALUES
(
  GENERATE_UUID(),
  'pipeline_transactions',
  'datos_transacciones.csv',
  CURRENT_TIMESTAMP(),
  CURRENT_TIMESTAMP(),
  1000,
  1000,
  0,
  'SUCCESS',
  NULL
);