# IAM Module - Variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "cloud_run_service_account_id" {
  description = "ID for the Cloud Run service account"
  type        = string
}

variable "cloud_build_service_account_id" {
  description = "ID for the Cloud Build service account"
  type        = string
}
