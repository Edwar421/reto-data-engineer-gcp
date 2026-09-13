-- ============================================================
-- VISTA DE MONITOREO DETALLADO
-- ============================================================

CREATE OR REPLACE VIEW `dwh-bdb.bdb_dwh.vw_pipeline_monitoring` AS
SELECT
  a.execution_id,
  a.pipeline_name,
  a.source_file,
  a.start_time,
  a.end_time,

  TIMESTAMP_DIFF(
    a.end_time,
    a.start_time,
    SECOND
  ) AS duration_seconds,

  a.rows_read,
  a.rows_processed,
  a.rows_rejected,
  a.status,
  a.error_message,

  q.critical_failures,
  q.warnings,
  q.decision AS quality_gate_decision

FROM `dwh-bdb.bdb_dwh.audit_pipeline` AS a

LEFT JOIN `dwh-bdb.bdb_dwh.quality_gate` AS q
  ON a.execution_id = q.execution_id;