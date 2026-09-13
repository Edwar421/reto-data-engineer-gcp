resource "google_service_account" "cicd" {
  account_id   = "sa-dwh-cicd-${var.environment}"
  display_name = "CI/CD DWH (${var.environment})"
  description  = "Identidad usada por GitHub Actions (WIF) para Terraform y el pipeline SQL."
  project      = var.project_id

  depends_on = [google_project_service.apis]
}

resource "google_project_iam_member" "cicd" {
  for_each = toset(local.cicd_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cicd.email}"
}

resource "google_storage_bucket_iam_member" "cicd_raw" {
  bucket = google_storage_bucket.raw.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cicd.email}"
}

resource "google_storage_bucket_iam_member" "cicd_scripts" {
  bucket = google_storage_bucket.scripts.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cicd.email}"
}
