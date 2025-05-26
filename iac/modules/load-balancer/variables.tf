# Load Balancer Module - Variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for resources deployment"
  type        = string
}

variable "frontend_service_name" {
  description = "Name of the frontend Cloud Run service"
  type        = string
}

variable "backend_service_name" {
  description = "Name of the backend Cloud Run service"
  type        = string
}

variable "frontend_url" {
  description = "URL of the frontend Cloud Run service"
  type        = string
}

variable "backend_url" {
  description = "URL of the backend Cloud Run service"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the load balancer"
  type        = string
  default     = ""
}

variable "enable_cdn" {
  description = "Whether to enable CDN for the load balancer"
  type        = bool
  default     = false
}
