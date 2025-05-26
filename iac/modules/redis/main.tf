# Redis Module - Creates Memorystore (Redis) instance in private VPC

resource "google_redis_instance" "cache" {
  name           = var.redis_name
  tier           = var.redis_tier
  memory_size_gb = var.memory_size_gb
  region         = var.region
  
  authorized_network = var.network_id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  
  redis_version     = var.redis_version
  display_name      = "Learning Platform Redis Cache"
  redis_configs     = {
    "maxmemory-policy" : "allkeys-lru"
  }
  
  auth_enabled = true
  transit_encryption_mode = "DISABLED"  # Private network so transit encryption not required
  
  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"
      start_time {
        hours   = 2
        minutes = 0
      }
    }
  }
  
  lifecycle {
    prevent_destroy = true
  }
}
