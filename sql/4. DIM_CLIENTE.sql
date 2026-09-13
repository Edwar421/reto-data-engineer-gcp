CREATE OR REPLACE TABLE `dwh-bdb.bdb_dwh.dim_cliente` AS
SELECT
  ROW_NUMBER() OVER (
    ORDER BY numero_identificacion
  ) AS id_cliente,

  numero_identificacion,
  tipo_identificacion,
  nombres,
  ciudad,
  fecha_nacimiento,
  direccion_cliente,
  telefono_cliente,
  correo_cliente

FROM (
  SELECT DISTINCT
    numero_identificacion,
    tipo_identificacion,
    nombres,
    ciudad,
    fecha_nacimiento,
    direccion_cliente,
    telefono_cliente,
    correo_cliente

  FROM `dwh-bdb.bdb_dwh.stg_transactions_clean`

  WHERE numero_identificacion IS NOT NULL
);