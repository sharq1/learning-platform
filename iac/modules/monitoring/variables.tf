# Monitoring Module - Variables

variable "project_id" {
  description = "GCP Project ID"
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
