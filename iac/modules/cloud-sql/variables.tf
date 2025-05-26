# Cloud SQL Module - Variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for resources deployment"
  type        = string
}

variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
}

variable "db_user" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database user"
  type        = string
  sensitive   = true
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
