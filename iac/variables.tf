# variables.tf - Input variables definition for Learning Platform Infrastructure

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for resources deployment"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "learning-platform-network"
}

# Database variables
variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "learning_platform"
}

variable "db_user" {
  description = "Username for the database"
  type        = string
  default     = "app_user"
}

variable "db_instance_tier" {
  description = "Machine type for the Cloud SQL instance"
  type        = string
  default     = "db-g1-small"
}

variable "db_version" {
  description = "PostgreSQL version for the Cloud SQL instance"
  type        = string
  default     = "POSTGRES_14"
}

# Redis variables
variable "redis_name" {
  description = "Name for the Redis instance"
  type        = string
  default     = "learning-platform-redis"
}

variable "redis_tier" {
  description = "Tier for Redis instance"
  type        = string
  default     = "BASIC"
}

# Storage variables
variable "bucket_name" {
  description = "Name of the Cloud Storage bucket for learning materials"
  type        = string
  default     = "learning-materials"
}

# Cloud Run variables
variable "frontend_service_name" {
  description = "Name of the frontend Cloud Run service"
  type        = string
  default     = "learning-platform-frontend"
}

variable "backend_service_name" {
  description = "Name of the backend Cloud Run service"
  type        = string
  default     = "learning-platform-backend"
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

# IAM variables
variable "cloud_run_service_account_id" {
  description = "ID for the Cloud Run service account"
  type        = string
  default     = "cloud-run-sa"
}

variable "cloud_build_service_account_id" {
  description = "ID for the Cloud Build service account"
  type        = string
  default     = "cloud-build-sa"
}

# Cloud Build variables
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

# Load Balancer variables
variable "enable_cdn" {
  description = "Whether to enable CDN for the load balancer"
  type        = bool
  default     = false
}

# Monitoring variables
variable "error_rate_threshold" {
  description = "Error rate threshold for alert policy (percentage)"
  type        = number
  default     = 5
}

variable "notification_channels" {
  description = "List of notification channel IDs for alerts"
  type        = list(string)
  default     = []
}
