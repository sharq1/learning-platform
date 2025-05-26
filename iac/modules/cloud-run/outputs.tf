# Cloud Run Module - Outputs

output "frontend_url" {
  description = "The URL of the frontend Cloud Run service"
  value       = google_cloud_run_service.frontend.status[0].url
}

output "backend_url" {
  description = "The URL of the backend Cloud Run service"
  value       = google_cloud_run_service.backend.status[0].url
}

output "frontend_service_id" {
  description = "The ID of the frontend Cloud Run service"
  value       = google_cloud_run_service.frontend.id
}

output "backend_service_id" {
  description = "The ID of the backend Cloud Run service"
  value       = google_cloud_run_service.backend.id
}

output "frontend_latest_revision_name" {
  description = "The latest revision name of the frontend Cloud Run service"
  value       = google_cloud_run_service.frontend.status[0].latest_created_revision_name
}

output "backend_latest_revision_name" {
  description = "The latest revision name of the backend Cloud Run service"
  value       = google_cloud_run_service.backend.status[0].latest_created_revision_name
}
