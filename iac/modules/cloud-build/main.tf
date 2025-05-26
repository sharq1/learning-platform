# Cloud Build Module - Creates Cloud Build trigger for GitHub repository

# Create Artifact Registry repository for Docker images
resource "google_artifact_registry_repository" "repo" {
  provider = google-beta

  location      = var.region
  repository_id = "learning-platform"
  description   = "Docker repository for learning platform images"
  format        = "DOCKER"
}

# GitHub connection for Cloud Build
resource "google_cloudbuild_trigger" "github_trigger" {
  name        = "github-trigger"
  description = "Trigger for GitHub repository"
  
  github {
    owner = var.github_owner
    name  = var.github_repo
    
    push {
      branch = "^${var.branch_name}$"
    }
  }
  
  # Build configuration for frontend
  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${var.frontend_service_name}:$${SHORT_SHA}",
        "-f", "./frontend/Dockerfile",
        "./frontend"
      ]
    }
    
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${var.frontend_service_name}:$${SHORT_SHA}"
      ]
    }
    
    # Build configuration for backend
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${var.backend_service_name}:$${SHORT_SHA}",
        "-f", "./backend/Dockerfile",
        "./backend"
      ]
    }
    
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${var.backend_service_name}:$${SHORT_SHA}"
      ]
    }
    
    # Deploy frontend to Cloud Run
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = [
        "run", "deploy", var.frontend_service_name,
        "--image", "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${var.frontend_service_name}:$${SHORT_SHA}",
        "--region", var.region,
        "--service-account", var.service_account_email,
        "--platform", "managed"
      ]
    }
    
    # Deploy backend to Cloud Run
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = [
        "run", "deploy", var.backend_service_name,
        "--image", "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${var.backend_service_name}:$${SHORT_SHA}",
        "--region", var.region,
        "--service-account", var.service_account_email,
        "--platform", "managed"
      ]
    }
    
    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
    
    artifacts {
      images = [
        "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${var.frontend_service_name}:$${SHORT_SHA}",
        "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${var.backend_service_name}:$${SHORT_SHA}"
      ]
    }
  }
  
  # Use the service account
  service_account = var.service_account_email
  
  depends_on = [google_artifact_registry_repository.repo]
}
