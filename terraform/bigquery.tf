resource "google_bigquery_dataset" "dwh" {
  dataset_id                 = var.dataset_id
  project                    = var.project_id
  location                   = var.bq_location
  delete_contents_on_destroy = var.environment != "prod"
  labels                     = local.labels

  description = "DWH Bancolombia - staging, calidad, dimensiones y hechos"

  depends_on = [google_project_service.apis]
}

resource "google_bigquery_dataset_iam_member" "cicd_data_editor" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.dwh.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.cicd.email}"
}

resource "google_bigquery_dataset_iam_member" "cicd_job_user" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.dwh.dataset_id
  role       = "roles/bigquery.user"
  member     = "serviceAccount:${google_service_account.cicd.email}"
}
