variable "project_id" {
  description = "ID del proyecto GCP."
  type        = string
}

variable "region" {
  description = "Región del bucket de estado."
  type        = string
  default     = "us-central1"
}

variable "state_bucket_name" {
  description = "Nombre globalmente único del bucket de estado de Terraform. Si está vacío se usa <project_id>-tf-state."
  type        = string
  default     = ""
}
