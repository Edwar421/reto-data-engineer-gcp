CREATE OR REPLACE TABLE `dwh-bdb.bdb_dwh.dim_producto` AS
SELECT
  ROW_NUMBER() OVER (
    ORDER BY tipo_producto
  ) AS id_producto,

  tipo_producto

FROM (
  SELECT DISTINCT
    tipo_producto

  FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`

  WHERE tipo_producto IS NOT NULL
);