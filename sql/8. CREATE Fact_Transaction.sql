CREATE OR REPLACE TABLE `dwh-bdb.bdb_dwh.fact_transacciones`

PARTITION BY DATE(fecha_hora)

CLUSTER BY id_cliente, id_producto

AS

SELECT
  -- Identificador único
  TO_HEX(
    SHA256(
      CONCAT(
        CAST(st.numero_cuenta AS STRING),
        '|',
        CAST(st.fecha_hora AS STRING),
        '|',
        CAST(st.monto_transaccion AS STRING),
        '|',
        st.tipo_transaccion,
        '|',
        st.tipo_producto
      )
    )
  ) AS id_transaccion,

  -- Claves de dimensiones
  dc.id_cliente,
  dp.id_producto,
  df.id_fecha,
  dr.id_riesgo,

  -- Datos de la transacción
  st.numero_cuenta,
  st.fecha_hora,
  st.monto_transaccion,
  st.tipo_transaccion

FROM `dwh-bdb.bdb_dwh.stg_transactions_clean` AS st

INNER JOIN `dwh-bdb.bdb_dwh.dim_cliente` AS dc
  ON st.numero_identificacion = dc.numero_identificacion

INNER JOIN `dwh-bdb.bdb_dwh.dim_producto` AS dp
  ON st.tipo_producto = dp.tipo_producto

INNER JOIN `dwh-bdb.bdb_dwh.dim_riesgo` AS dr
  ON st.reporte_riesgo = dr.reporte_riesgo
  AND COALESCE(st.monto_riesgo, -1)
      = COALESCE(dr.monto_riesgo, -1)
  AND COALESCE(st.tiempo_mora_dias, -1)
      = COALESCE(dr.tiempo_mora_dias, -1)

INNER JOIN `dwh-bdb.bdb_dwh.dim_fecha` AS df
  ON DATE(st.fecha_hora) = df.fecha;