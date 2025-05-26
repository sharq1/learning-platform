# Secrets Module - Outputs

output "db_password" {
  description = "The generated database password"
  value       = random_password.db_password.result
  sensitive   = true
}

output "redis_password" {
  description = "The generated Redis password"
  value       = random_password.redis_password.result
  sensitive   = true
}

output "db_password_secret_id" {
  description = "The ID of the database password secret"
  value       = google_secret_manager_secret.db_password.id
}

output "redis_password_secret_id" {
  description = "The ID of the Redis password secret"
  value       = google_secret_manager_secret.redis_password.id
}
