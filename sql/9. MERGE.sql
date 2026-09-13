MERGE `dwh-bdb.bdb_dwh.fact_transacciones` AS destino

USING (
  SELECT
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

    dc.id_cliente,
    dp.id_producto,
    df.id_fecha,
    dr.id_riesgo,

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
    ON DATE(st.fecha_hora) = df.fecha

) AS origen

ON destino.id_transaccion = origen.id_transaccion

WHEN MATCHED THEN
  UPDATE SET
    id_cliente = origen.id_cliente,
    id_producto = origen.id_producto,
    id_fecha = origen.id_fecha,
    id_riesgo = origen.id_riesgo,
    numero_cuenta = origen.numero_cuenta,
    fecha_hora = origen.fecha_hora,
    monto_transaccion = origen.monto_transaccion,
    tipo_transaccion = origen.tipo_transaccion

WHEN NOT MATCHED THEN
  INSERT (
    id_transaccion,
    id_cliente,
    id_producto,
    id_fecha,
    id_riesgo,
    numero_cuenta,
    fecha_hora,
    monto_transaccion,
    tipo_transaccion
  )
  VALUES (
    origen.id_transaccion,
    origen.id_cliente,
    origen.id_producto,
    origen.id_fecha,
    origen.id_riesgo,
    origen.numero_cuenta,
    origen.fecha_hora,
    origen.monto_transaccion,
    origen.tipo_transaccion
  );