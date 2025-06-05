# Cloud Build Module - Creates Cloud Build trigger for GitHub repository

# Get project information
data "google_project" "project" {
  project_id = var.project_id
}

locals {
  # Determine which service name to use, with backward compatibility
  effective_service_name = coalesce(
    var.service_name != "" ? var.service_name : null,
    var.frontend_service_name != "" ? var.frontend_service_name : null,
    "learning-platform-api"  # Default fallback
  )
  
  # Cloud Build IAM permissions
  cloudbuild_sa = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  cloud_run_admin = "roles/run.admin"
  iam_sa_user    = "roles/iam.serviceAccountUser"
  cloudbuild_sa_roles = [
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/cloudbuild.builds.builder"
  ]
}

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
  
  # Build configuration for the service
  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${local.effective_service_name}:$${SHORT_SHA}",
        "-f", "./app/Dockerfile",
        "."
      ]
    }
    
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${local.effective_service_name}:$${SHORT_SHA}"
      ]
    }
    
    # Deploy service to Cloud Run
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = [
        "run", "deploy", local.effective_service_name,
        "--image", "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${local.effective_service_name}:$${SHORT_SHA}",
        "--region", var.region,
        "--service-account", var.cloud_run_sa_for_deployment_email,
        "--platform", "managed"
      ]
    }
    
    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
    
    artifacts {
      images = [
        "${var.region}-docker.pkg.dev/${var.project_id}/learning-platform/${local.effective_service_name}:$${SHORT_SHA}"
      ]
    }
  }
  
  depends_on = [google_artifact_registry_repository.repo]
}
