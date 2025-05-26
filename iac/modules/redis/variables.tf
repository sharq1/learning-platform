# Redis Module - Variables

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

variable "redis_name" {
  description = "Name for the Redis instance"
  type        = string
}

variable "redis_tier" {
  description = "Tier for Redis instance"
  type        = string
  default     = "BASIC"
}

variable "memory_size_gb" {
  description = "Redis memory size in GB"
  type        = number
  default     = 1
}

variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = "REDIS_6_X"
}

variable "redis_password" {
  description = "Password for Redis AUTH"
  type        = string
  sensitive   = true
}
