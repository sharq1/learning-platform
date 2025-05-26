# Cloud Run Module - Outputs

output "api_url" {
  description = "The URL of the FastAPI Cloud Run service"
  value       = google_cloud_run_service.api.status[0].url
}

output "api_service_id" {
  description = "The ID of the FastAPI Cloud Run service"
  value       = google_cloud_run_service.api.id
}

output "api_latest_revision_name" {
  description = "The latest revision name of the FastAPI Cloud Run service"
  value       = google_cloud_run_service.api.status[0].latest_created_revision_name
}

# Backward compatibility outputs
output "frontend_url" {
  description = "The URL of the frontend Cloud Run service (deprecated, use api_url)"
  value       = google_cloud_run_service.api.status[0].url
}

output "backend_url" {
  description = "The URL of the backend Cloud Run service (deprecated, use api_url)"
  value       = google_cloud_run_service.api.status[0].url
}
