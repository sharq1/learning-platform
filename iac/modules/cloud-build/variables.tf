# Cloud Build Module - Variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for resources deployment"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "branch_name" {
  description = "GitHub branch to trigger build on"
  type        = string
  default     = "master"
}

variable "service_name" {
  description = "Name of the FastAPI Cloud Run service"
  type        = string
  default     = ""  # Default to empty string for backward compatibility
}

# Backward compatibility variables
variable "frontend_service_name" {
  description = "Name of the frontend Cloud Run service (deprecated, use service_name)"
  type        = string
  default     = ""
}

variable "backend_service_name" {
  description = "Name of the backend Cloud Run service (deprecated, use service_name)"
  type        = string
  default     = ""
}

variable "cloud_build_trigger_sa_email" {
  description = "Email of the service account that the Cloud Build trigger itself will use."
  type        = string
}

variable "cloud_run_sa_for_deployment_email" {
  description = "Email of the service account that the Cloud Run service will use (passed to 'gcloud run deploy --service-account')"
  type        = string
}
