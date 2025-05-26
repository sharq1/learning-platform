# Monitoring Module - Variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "service_name" {
  description = "Name of the FastAPI Cloud Run service"
  type        = string
  default     = ""  # Default value to avoid errors during planning
}

variable "frontend_service_name" {
  description = "Name of the frontend Cloud Run service (deprecated, use service_name)"
  type        = string
  default     = ""  # Default value to avoid errors during planning
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
