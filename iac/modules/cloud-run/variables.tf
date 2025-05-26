# Cloud Run Module - Variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for resources deployment"
  type        = string
}

variable "service_name" {
  description = "Name of the FastAPI Cloud Run service"
  type        = string
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

variable "service_image" {
  description = "Docker image for the FastAPI service"
  type        = string
  default     = ""
}

variable "vpc_connector_id" {
  description = "ID of the Serverless VPC Access connector"
  type        = string
}

variable "storage_bucket_name" {
  description = "Name of the Cloud Storage bucket for static assets"
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "Email of the service account for Cloud Run"
  type        = string
}

variable "db_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_user" {
  description = "Username for the database"
  type        = string
}

variable "redis_host" {
  description = "Host of the Redis instance"
  type        = string
}

variable "redis_port" {
  description = "Port of the Redis instance"
  type        = string
}

variable "redis_password_secret" {
  description = "ID of the Secret Manager secret containing the Redis password"
  type        = string
  default     = "redis-password"
}

variable "db_password_secret" {
  description = "ID of the Secret Manager secret containing the database password"
  type        = string
  default     = "db-password"
}

variable "min_instances" {
  description = "Minimum number of instances for Cloud Run services"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances for Cloud Run services"
  type        = number
  default     = 10
}

variable "concurrency" {
  description = "Maximum number of concurrent requests per instance"
  type        = number
  default     = 80
}
