# Monitoring Module - Outputs

output "api_error_rate_policy_id" {
  description = "The ID of the API service error rate alert policy"
  value       = google_monitoring_alert_policy.api_error_rate.id
}

output "api_latency_policy_id" {
  description = "The ID of the API service latency alert policy"
  value       = google_monitoring_alert_policy.api_latency.id
}

output "cloudsql_cpu_policy_id" {
  description = "The ID of the Cloud SQL CPU utilization alert policy"
  value       = google_monitoring_alert_policy.cloudsql_cpu.id
}

output "dashboard_name" {
  description = "The name of the monitoring dashboard"
  value       = google_monitoring_dashboard.learning_platform_dashboard.id
}
