# Storage Module - Outputs

output "bucket_name" {
  description = "The name of the storage bucket"
  value       = google_storage_bucket.learning_materials.name
}

output "bucket_url" {
  description = "The URL of the storage bucket"
  value       = google_storage_bucket.learning_materials.url
}

output "bucket_self_link" {
  description = "The self link of the storage bucket"
  value       = google_storage_bucket.learning_materials.self_link
}
