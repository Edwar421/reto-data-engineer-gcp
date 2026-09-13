CREATE OR REPLACE TABLE `dwh-bdb.bdb_dwh.dim_fecha` AS
SELECT
  CAST(
    FORMAT_DATE('%Y%m%d', fecha)
    AS INT64
  ) AS id_fecha,

  fecha,

  EXTRACT(DAY FROM fecha) AS dia,
  EXTRACT(MONTH FROM fecha) AS mes,
  EXTRACT(YEAR FROM fecha) AS anio,
  EXTRACT(QUARTER FROM fecha) AS trimestre

FROM UNNEST(
  GENERATE_DATE_ARRAY(
    (
      SELECT MIN(DATE(fecha_hora))
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
    ),
    (
      SELECT MAX(DATE(fecha_hora))
      FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`
    )
  )
) AS fecha;