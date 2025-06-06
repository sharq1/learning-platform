# Cloud Run Module - Creates FastAPI Cloud Run service

# FastAPI Cloud Run service
resource "google_cloud_run_service" "api" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.service_image != "" ? var.service_image : "gcr.io/cloudrun/placeholder"
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        # Environment variables from secrets
        env {
          name  = "DB_HOST"
          value = "/cloudsql/${var.db_connection_name}"
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

        env {
          name  = "MATERIALS_BUCKET"
          value = var.materials_bucket_name
        }

        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = var.project_id
        }

        env {
          name = "JWT_SECRET"
          value_from {
            secret_key_ref {
              name = "projects/${var.project_id}/secrets/jwt-secret"
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

  depends_on = [
    var.vpc_connector_resource_for_dependency,
    var.private_service_networking_connection_for_dependency
  ]
}

# IAM policy to make the API service public
resource "google_cloud_run_service_iam_member" "api_public" {
  location = google_cloud_run_service.api.location
  service  = google_cloud_run_service.api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
