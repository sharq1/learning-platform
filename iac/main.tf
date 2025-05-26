# main.tf - Learning Platform Infrastructure

# Provider configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "run.googleapis.com",
    "vpcaccess.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "storage.googleapis.com"
  ])

  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Network Infrastructure
module "vpc" {
  source       = "./modules/vpc"
  project_id   = var.project_id
  region       = var.region
  network_name = var.network_name

  depends_on = [google_project_service.apis]
}

# Cloud SQL
module "cloud_sql" {
  source     = "./modules/cloud-sql"
  project_id = var.project_id
  region     = var.region
  network_id = module.vpc.network_id

  db_name     = var.db_name
  db_user     = var.db_user
  db_password = module.secrets.db_password

  depends_on = [
    google_project_service.apis,
    module.vpc
  ]
}

# Redis
module "redis" {
  source     = "./modules/redis"
  project_id = var.project_id
  region     = var.region
  network_id = module.vpc.network_id

  redis_name     = var.redis_name
  redis_tier     = var.redis_tier
  redis_password = module.secrets.redis_password

  depends_on = [
    google_project_service.apis,
    module.vpc
  ]
}

# Storage
module "storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  region     = var.region

  bucket_name = var.bucket_name

  depends_on = [google_project_service.apis]
}

# Secrets
module "secrets" {
  source     = "./modules/secrets"
  project_id = var.project_id

  depends_on = [google_project_service.apis]
}

# IAM
module "iam" {
  source     = "./modules/iam"
  project_id = var.project_id

  cloud_run_service_account_id  = var.cloud_run_service_account_id
  cloud_build_service_account_id = var.cloud_build_service_account_id

  depends_on = [google_project_service.apis]
}

# Cloud Run
module "cloud_run" {
  source     = "./modules/cloud-run"
  project_id = var.project_id
  region     = var.region
  
  # Use coalesce to handle backward compatibility
  service_name = coalesce(
    try(var.service_name, "") != "" ? var.service_name : null,
    try(var.frontend_service_name, "") != "" ? var.frontend_service_name : null,
    "learning-platform-api"  # Default fallback
  )
  
  frontend_service_name = coalesce(
    try(var.frontend_service_name, "") != "" ? var.frontend_service_name : null,
    try(var.service_name, "") != "" ? var.service_name : null,
    "learning-platform-api"  # Default fallback
  )
  
  backend_service_name = coalesce(
    try(var.backend_service_name, "") != "" ? var.backend_service_name : null,
    try(var.service_name, "") != "" ? var.service_name : null,
    "learning-platform-api"  # Default fallback
  )
  
  min_instances = var.min_instances
  max_instances = var.max_instances
  concurrency   = var.concurrency
  
  vpc_connector_id = module.vpc.connector_id
  
  db_connection_name = module.cloud_sql.connection_name
  db_name            = var.db_name
  db_user            = var.db_user
  
  redis_host         = module.redis.redis_host
  redis_port         = module.redis.redis_port
  
  service_account_email = module.iam.cloud_run_service_account_email
  
  depends_on = [
    google_project_service.apis,
    module.vpc,
    module.cloud_sql,
    module.redis,
    module.secrets,
    module.iam
  ]
}

# Cloud Build
module "cloud_build" {
  source     = "./modules/cloud-build"
  project_id = var.project_id
  region     = var.region
  
  service_name = coalesce(
    try(var.service_name, "") != "" ? var.service_name : null,
    try(var.frontend_service_name, "") != "" ? var.frontend_service_name : null,
    "learning-platform-api"  # Default fallback
  )
  
  github_owner     = var.github_owner
  github_repo      = var.github_repo
  branch_name      = var.branch_name
  
  service_account_email = module.iam.cloud_build_service_account_email

  depends_on = [
    google_project_service.apis,
    module.cloud_run,
    module.iam
  ]
}

# Load Balancer
module "load_balancer" {
  source     = "./modules/load-balancer"
  project_id = var.project_id
  region     = var.region
  
  # Use coalesce to handle backward compatibility
  service_name = coalesce(
    try(var.service_name, "") != "" ? var.service_name : null,
    try(var.frontend_service_name, "") != "" ? var.frontend_service_name : null,
    "learning-platform-api"  # Default fallback
  )
  
  frontend_service_name = coalesce(
    try(var.frontend_service_name, "") != "" ? var.frontend_service_name : null,
    try(var.service_name, "") != "" ? var.service_name : null,
    "learning-platform-api"  # Default fallback
  )
  
  backend_service_name = coalesce(
    try(var.backend_service_name, "") != "" ? var.backend_service_name : null,
    try(var.service_name, "") != "" ? var.service_name : null,
    "learning-platform-api"  # Default fallback
  )
  
  service_url  = module.cloud_run.api_url
  frontend_url = module.cloud_run.frontend_url # For backward compatibility
  backend_url  = module.cloud_run.backend_url  # For backward compatibility
  
  enable_cdn    = var.enable_cdn

  depends_on = [
    google_project_service.apis,
    module.cloud_run
  ]
}

# Monitoring
module "monitoring" {
  source     = "./modules/monitoring"
  project_id = var.project_id
  
  # Use coalesce to handle backward compatibility
  service_name = coalesce(
    try(var.service_name, "") != "" ? var.service_name : null,
    try(var.frontend_service_name, "") != "" ? var.frontend_service_name : null,
    "learning-platform-api"  # Default fallback
  )
  
  frontend_service_name = coalesce(
    try(var.frontend_service_name, "") != "" ? var.frontend_service_name : null,
    try(var.service_name, "") != "" ? var.service_name : null,
    "learning-platform-api"  # Default fallback
  )
  
  error_rate_threshold = var.error_rate_threshold
  notification_channels = var.notification_channels

  depends_on = [
    google_project_service.apis,
    module.cloud_run
  ]
}
