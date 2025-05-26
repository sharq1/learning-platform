# IAM Module - Outputs

output "cloud_run_service_account_email" {
  description = "The email of the Cloud Run service account"
  value       = google_service_account.cloud_run_service_account.email
}

output "cloud_build_service_account_email" {
  description = "The email of the Cloud Build service account"
  value       = google_service_account.cloud_build_service_account.email
}

output "cloud_run_service_account_id" {
  description = "The ID of the Cloud Run service account"
  value       = google_service_account.cloud_run_service_account.id
}

output "cloud_build_service_account_id" {
  description = "The ID of the Cloud Build service account"
  value       = google_service_account.cloud_build_service_account.id
}
