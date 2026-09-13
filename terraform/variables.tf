variable "project_id" {
  description = "ID del proyecto GCP donde vive el DWH."
  type        = string
}

variable "region" {
  description = "Región por defecto para recursos regionales (GCS, WIF)."
  type        = string
  default     = "us-central1"
}

variable "bq_location" {
  description = "Ubicación de BigQuery (US, EU o región). Debe coincidir con el bucket raw."
  type        = string
  default     = "US"
}

variable "dataset_id" {
  description = "Dataset de BigQuery del DWH (staging, dims, facts, DQ)."
  type        = string
  default     = "bdb_dwh"
}

variable "environment" {
  description = "Ambiente lógico (dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment debe ser dev, staging o prod."
  }
}

variable "github_repository" {
  description = "Repositorio de GitHub en formato owner/repo para Workload Identity Federation."
  type        = string
  default     = "Edwar421/reto-data-engineer-gcp"
}

variable "github_branch" {
  description = "Rama autorizada para terraform apply vía WIF. Vacío = cualquier rama del repo."
  type        = string
  default     = "main"
}

variable "labels" {
  description = "Labels comunes para todos los recursos."
  type        = map(string)
  default     = {}
}
