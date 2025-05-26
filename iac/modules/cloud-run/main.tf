# Cloud Run Module - Creates Cloud Run services for frontend and backend

# Frontend Cloud Run service
resource "google_cloud_run_service" "frontend" {
  name     = var.frontend_service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.frontend_image != "" ? var.frontend_image : "gcr.io/cloudrun/placeholder"
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        # Environment variables from secrets
        env {
          name  = "DB_HOST"
          value = var.db_connection_name
        }
        
        env {
          name  = "DB_NAME"
          value = var.db_name
        }
        
        env {
          name  = "DB_USER"
          value = var.db_user
        }
        
        env {
          name = "DB_PASSWORD"
          value_from {
            secret_key_ref {
              name = "db-password"
              key  = "latest"
            }
          }
        }
        
        env {
          name  = "REDIS_HOST"
          value = var.redis_host
        }
        
        env {
          name  = "REDIS_PORT"
          value = var.redis_port
        }
        
        env {
          name = "REDIS_PASSWORD"
          value_from {
            secret_key_ref {
              name = "redis-password"
              key  = "latest"
            }
          }
        }
      }
      
      # Set the service account
      service_account_name = var.service_account_email
      
      # Set the container concurrency
      container_concurrency = var.concurrency
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = var.min_instances
        "autoscaling.knative.dev/maxScale" = var.max_instances
        
        # Use VPC connector
        "run.googleapis.com/vpc-access-connector" = var.vpc_connector_id
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
        
        # Cloud SQL connection
        "run.googleapis.com/cloudsql-instances" = var.db_connection_name
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  autogenerate_revision_name = true
}

# Backend Cloud Run service
resource "google_cloud_run_service" "backend" {
  name     = var.backend_service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.backend_image != "" ? var.backend_image : "gcr.io/cloudrun/placeholder"
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
        }
        
        # Environment variables from secrets
        env {
          name  = "DB_HOST"
          value = var.db_connection_name
        }
        
        env {
          name  = "DB_NAME"
          value = var.db_name
        }
        
        env {
          name  = "DB_USER"
          value = var.db_user
        }
        
        env {
          name = "DB_PASSWORD"
          value_from {
            secret_key_ref {
              name = "db-password"
              key  = "latest"
            }
          }
        }
        
        env {
          name  = "REDIS_HOST"
          value = var.redis_host
        }
        
        env {
          name  = "REDIS_PORT"
          value = var.redis_port
        }
        
        env {
          name = "REDIS_PASSWORD"
          value_from {
            secret_key_ref {
              name = "redis-password"
              key  = "latest"
            }
          }
        }
      }
      
      # Set the service account
      service_account_name = var.service_account_email
      
      # Set the container concurrency
      container_concurrency = var.concurrency
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = var.min_instances
        "autoscaling.knative.dev/maxScale" = var.max_instances
        
        # Use VPC connector
        "run.googleapis.com/vpc-access-connector" = var.vpc_connector_id
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
        
        # Cloud SQL connection
        "run.googleapis.com/cloudsql-instances" = var.db_connection_name
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  autogenerate_revision_name = true
}

# IAM policy to make the frontend service public
resource "google_cloud_run_service_iam_member" "frontend_public" {
  location = google_cloud_run_service.frontend.location
  service  = google_cloud_run_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# IAM policy to make the backend service public
resource "google_cloud_run_service_iam_member" "backend_public" {
  location = google_cloud_run_service.backend.location
  service  = google_cloud_run_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
