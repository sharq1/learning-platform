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
  location    = var.region
  name        = "learning-platform-pushed"
  description = "Trigger for GitHub repository"
  
  service_account = "projects/learning-platform-461008/serviceAccounts/cloud-build-sa@learning-platform-461008.iam.gserviceaccount.com"  # Must be full path; short email causes API error 400 with complex builds.

  repository_event_config {
    repository = "projects/learning-platform-461008/locations/us-central1/connections/github/repositories/learning-platform"
    push {
      branch = "^${var.branch_name}$"
    }
  }
  
  # Build configuration for the service
  build {
    timeout = "600s" # 10 minutes
    images = [
      "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.name}/${local.effective_service_name}:$${SHORT_SHA}"
    ]
    # Define artifacts (e.g., Docker images to be pushed)
    artifacts {
      images = [
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.name}/${local.effective_service_name}:$${SHORT_SHA}"
      ]
    }

    options {
      logging = "CLOUD_LOGGING_ONLY"
    }

    # Define build steps
    # Step 1: Build the Docker image
    step {
      name = "gcr.io/cloud-builders/docker"
      dir  = "app/"
      args = [
        "build",
        "-t",
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.name}/${local.effective_service_name}:$${SHORT_SHA}",
        "-f",
        "Dockerfile", # Path to the Dockerfile
        "."                   # Build context (current directory in the repo)
      ]
    }

    # Step 2: Push the Docker image to Artifact Registry
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.name}/${local.effective_service_name}:$${SHORT_SHA}"
      ]
    }

    # Step 3: Deploy the service to Cloud Run
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = [
        "run", "deploy", local.effective_service_name,
        "--image", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.name}/${local.effective_service_name}:$${SHORT_SHA}",
        "--region", var.region,
        "--service-account", var.cloud_run_sa_for_deployment_email,
        "--platform", "managed"
      ]
    }
  }
}
