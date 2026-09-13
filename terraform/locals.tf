locals {
  labels = merge(
    {
      project     = "reto-dwh"
      environment = var.environment
      managed_by  = "terraform"
    },
    var.labels
  )

  raw_bucket_name     = "${var.project_id}-dwh-raw-${var.environment}"
  scripts_bucket_name = "${var.project_id}-dwh-scripts-${var.environment}"

  apis = [
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "serviceusage.googleapis.com",
  ]

  cicd_roles = [
    "roles/bigquery.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
  ]
}
