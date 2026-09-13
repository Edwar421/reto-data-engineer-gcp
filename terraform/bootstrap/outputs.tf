output "state_bucket" {
  value       = google_storage_bucket.tfstate.name
  description = "Usar este valor en terraform/backend.hcl y en la variable de GitHub TF_STATE_BUCKET."
}

output "backend_hcl" {
  value = <<-EOT
    bucket = "${google_storage_bucket.tfstate.name}"
    prefix = "dwh/dev"
  EOT
}
