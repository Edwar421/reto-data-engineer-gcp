CREATE TABLE IF NOT EXISTS `dwh-bdb.bdb_dwh.quality_gate`
(
  execution_id STRING,
  critical_failures INT64,
  warnings INT64,
  decision STRING,
  execution_time TIMESTAMP
);

INSERT INTO `dwh-bdb.bdb_dwh.quality_gate`
(
  execution_id,
  critical_failures,
  warnings,
  decision,
  execution_time
)

WITH ultima_ejecucion AS (
  SELECT execution_id
  FROM `dwh-bdb.bdb_dwh.dq_results`
  ORDER BY execution_time DESC
  LIMIT 1
)

SELECT
  dq.execution_id,

  COUNTIF(
    dq.severity = 'CRITICAL'
    AND dq.status = 'FAIL'
  ) AS critical_failures,

  COUNTIF(
    dq.status = 'WARNING'
  ) AS warnings,

  CASE
    WHEN COUNTIF(
      dq.severity = 'CRITICAL'
      AND dq.status = 'FAIL'
    ) = 0
    THEN 'ALLOW'
    ELSE 'BLOCK'
  END AS decision,

  CURRENT_TIMESTAMP() AS execution_time

FROM `dwh-bdb.bdb_dwh.dq_results` dq
JOIN ultima_ejecucion ue
  ON dq.execution_id = ue.execution_id

GROUP BY dq.execution_id;