#!/usr/bin/env bash
# Ejecuta el pipeline SQL del DWH contra BigQuery.
# Requiere: bq, gcloud autenticado (WIF en CI o ADC en local).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SQL_DIR="${ROOT}/sql"

PROJECT_ID="${PROJECT_ID:-${GCP_PROJECT_ID:-}}"
BQ_DATASET="${BQ_DATASET:-bdb_dwh}"
BQ_LOCATION="${BQ_LOCATION:-US}"
RAW_BUCKET="${RAW_BUCKET:-}"

if [[ -z "${PROJECT_ID}" ]]; then
  echo "ERROR: define PROJECT_ID o GCP_PROJECT_ID" >&2
  exit 1
fi

if [[ -z "${RAW_BUCKET}" ]]; then
  echo "ERROR: define RAW_BUCKET" >&2
  exit 1
fi

CSV_URI="gs://${RAW_BUCKET}/raw/datos_transacciones.csv"

render_sql() {
  local file="$1"
  sed \
    -e "s/\${BQ_DATASET}/${BQ_DATASET}/g" \
    -e "s/\${PROJECT_ID}/${PROJECT_ID}/g" \
    -e "s/\${RAW_BUCKET}/${RAW_BUCKET}/g" \
    "${file}"
}

run_sql() {
  local file="$1"
  echo ""
  echo "==> $(basename "${file}")"
  render_sql "${file}" | bq query \
    --project_id="${PROJECT_ID}" \
    --location="${BQ_LOCATION}" \
    --use_legacy_sql=false \
    --nouse_cache \
    --quiet
}

echo "Proyecto : ${PROJECT_ID}"
echo "Dataset  : ${BQ_DATASET}"
echo "Location : ${BQ_LOCATION}"
echo "CSV      : ${CSV_URI}"

if ! gcloud storage ls "${CSV_URI}" >/dev/null 2>&1; then
  echo "ERROR: no existe ${CSV_URI}" >&2
  echo "Sube el CSV: gcloud storage cp datos_transacciones.csv ${CSV_URI}" >&2
  exit 1
fi

run_sql "${SQL_DIR}/1. Clean STG.sql"
run_sql "${SQL_DIR}/2. DataQuality.sql"

echo ""
echo "==> 3. quality_gate.sql"
GATE_JSON="$(render_sql "${SQL_DIR}/3. quality_gate.sql" | bq query \
  --project_id="${PROJECT_ID}" \
  --location="${BQ_LOCATION}" \
  --use_legacy_sql=false \
  --nouse_cache \
  --quiet \
  --format=json \
  --max_rows=100)"

if [[ -n "${GATE_JSON}" && "${GATE_JSON}" != "[]" ]]; then
  echo "QUALITY GATE FAILED — hay reglas en estado FAIL:" >&2
  echo "${GATE_JSON}" >&2
  exit 1
fi
echo "Quality gate OK"

run_sql "${SQL_DIR}/4. DIM_CLIENTE.sql"
run_sql "${SQL_DIR}/5. DIM_PRODUCTO.sql"
run_sql "${SQL_DIR}/6. DIM_RIESGO.sql"
run_sql "${SQL_DIR}/7. DIM_FECHA.sql"
run_sql "${SQL_DIR}/8. CREATE Fact_Transaction.sql"
run_sql "${SQL_DIR}/9. MERGE.sql"

echo ""
echo "Pipeline DWH completado."
