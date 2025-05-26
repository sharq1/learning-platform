# IAM Module - Creates service accounts and role bindings

# Create service account for Cloud Run
resource "google_service_account" "cloud_run_service_account" {
  account_id   = var.cloud_run_service_account_id
  display_name = "Cloud Run Service Account for Learning Platform"
  description  = "Service account used by Cloud Run services with least privilege"
}

# Create service account for Cloud Build
resource "google_service_account" "cloud_build_service_account" {
  account_id   = var.cloud_build_service_account_id
  display_name = "Cloud Build Service Account for Learning Platform"
  description  = "Service account used by Cloud Build pipelines"
}

# IAM binding for Cloud Run service account - Cloud SQL Client
resource "google_project_iam_member" "cloud_run_cloudsql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run_service_account.email}"
}

# IAM binding for Cloud Run service account - Redis Viewer
resource "google_project_iam_member" "cloud_run_redis" {
  project = var.project_id
  role    = "roles/redis.viewer"
  member  = "serviceAccount:${google_service_account.cloud_run_service_account.email}"
}

# IAM binding for Cloud Run service account - Logging Writer
resource "google_project_iam_member" "cloud_run_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_service_account.email}"
}

# IAM binding for Cloud Run service account - Secret Manager Secret Accessor
resource "google_project_iam_member" "cloud_run_secretmanager" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run_service_account.email}"
}

# IAM binding for Cloud Run service account - Storage Object Viewer
resource "google_project_iam_member" "cloud_run_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.cloud_run_service_account.email}"
}

# IAM binding for Cloud Build service account - Cloud Run Admin
resource "google_project_iam_member" "cloud_build_cloudrun" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloud_build_service_account.email}"
}

# IAM binding for Cloud Build service account - Service Account User
resource "google_project_iam_member" "cloud_build_serviceaccountuser" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloud_build_service_account.email}"
}

# IAM binding for Cloud Build service account - Storage Admin
resource "google_project_iam_member" "cloud_build_storage" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cloud_build_service_account.email}"
}

# IAM binding for Cloud Build service account - Artifact Registry Writer
resource "google_project_iam_member" "cloud_build_artifactregistry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloud_build_service_account.email}"
}
