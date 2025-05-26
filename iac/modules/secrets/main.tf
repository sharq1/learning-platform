# Secrets Module - Creates Secret Manager secrets for database and Redis passwords

# Generate random password for database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Generate random password for Redis
resource "random_password" "redis_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create Secret for database password
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  
  labels = {
    environment = "production"
    service     = "learning-platform"
  }
}

# Store the database password in the Secret
resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

# Create Secret for Redis password
resource "google_secret_manager_secret" "redis_password" {
  secret_id = "redis-password"
  
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  
  labels = {
    environment = "production"
    service     = "learning-platform"
  }
}

# Store the Redis password in the Secret
resource "google_secret_manager_secret_version" "redis_password" {
  secret      = google_secret_manager_secret.redis_password.id
  secret_data = random_password.redis_password.result
}
