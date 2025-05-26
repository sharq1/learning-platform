# Redis Module - Outputs

output "instance_id" {
  description = "The ID of the Redis instance"
  value       = google_redis_instance.cache.id
}

output "redis_host" {
  description = "The host of the Redis instance"
  value       = google_redis_instance.cache.host
}

output "redis_port" {
  description = "The port of the Redis instance"
  value       = google_redis_instance.cache.port
}
