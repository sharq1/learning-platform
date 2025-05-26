# Monitoring Module - Outputs

output "frontend_error_rate_policy_id" {
  description = "The ID of the frontend error rate alert policy"
  value       = google_monitoring_alert_policy.frontend_error_rate.id
}

output "backend_error_rate_policy_id" {
  description = "The ID of the backend error rate alert policy"
  value       = google_monitoring_alert_policy.backend_error_rate.id
}

output "backend_latency_policy_id" {
  description = "The ID of the backend latency alert policy"
  value       = google_monitoring_alert_policy.backend_latency.id
}

output "cloudsql_cpu_policy_id" {
  description = "The ID of the Cloud SQL CPU utilization alert policy"
  value       = google_monitoring_alert_policy.cloudsql_cpu.id
}

output "dashboard_name" {
  description = "The name of the monitoring dashboard"
  value       = google_monitoring_dashboard.learning_platform_dashboard.id
}
