CREATE OR REPLACE TABLE `dwh-bdb.bdb_dwh.dim_riesgo` AS
SELECT
  ROW_NUMBER() OVER (
    ORDER BY
      reporte_riesgo,
      monto_riesgo,
      tiempo_mora_dias
  ) AS id_riesgo,

  reporte_riesgo,
  monto_riesgo,
  tiempo_mora_dias

FROM (
  SELECT DISTINCT
    reporte_riesgo,
    monto_riesgo,
    tiempo_mora_dias

  FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`

  WHERE reporte_riesgo IS NOT NULL
);