output "project_id" {
  value = var.project_id
}

output "dataset_id" {
  value = google_bigquery_dataset.dwh.dataset_id
}

output "bq_location" {
  value = google_bigquery_dataset.dwh.location
}

output "raw_bucket" {
  value       = google_storage_bucket.raw.name
  description = "Bucket de landing. Sube el CSV a gs://<bucket>/raw/datos_transacciones.csv"
}

output "scripts_bucket" {
  value = google_storage_bucket.scripts.name
}

output "cicd_service_account" {
  value = google_service_account.cicd.email
}

output "workload_identity_provider" {
  value       = google_iam_workload_identity_pool_provider.github.name
  description = "Valor para la variable de GitHub WIF_PROVIDER"
}

output "github_actions_vars" {
  description = "Variables a configurar en GitHub (Settings > Secrets and variables > Actions > Variables)."
  value = {
    GCP_PROJECT_ID      = var.project_id
    ENVIRONMENT         = var.environment
    BQ_DATASET          = google_bigquery_dataset.dwh.dataset_id
    BQ_LOCATION         = google_bigquery_dataset.dwh.location
    RAW_BUCKET          = google_storage_bucket.raw.name
    WIF_PROVIDER        = google_iam_workload_identity_pool_provider.github.name
    WIF_SERVICE_ACCOUNT = google_service_account.cicd.email
    TF_STATE_BUCKET     = "usar output state_bucket del bootstrap"
  }
}
