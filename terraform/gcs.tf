resource "google_storage_bucket" "raw" {
  name                        = local.raw_bucket_name
  project                     = var.project_id
  location                    = var.bq_location
  uniform_bucket_level_access = true
  force_destroy               = var.environment != "prod"
  labels                      = local.labels

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  depends_on = [google_project_service.apis]
}

resource "google_storage_bucket" "scripts" {
  name                        = local.scripts_bucket_name
  project                     = var.project_id
  location                    = var.bq_location
  uniform_bucket_level_access = true
  force_destroy               = var.environment != "prod"
  labels                      = local.labels

  versioning {
    enabled = true
  }

  depends_on = [google_project_service.apis]
}

resource "google_storage_bucket_object" "raw_placeholder" {
  name    = "raw/.keep"
  bucket  = google_storage_bucket.raw.name
  content = "Upload datos_transacciones.csv to gs://${google_storage_bucket.raw.name}/raw/"
}
