# Sample terraform.tfvars with default values
# Update these values according to your GCP environment

# Project settings
project_id    = "your-gcp-project-id"
region        = "us-central1"
network_name  = "learning-platform-network"

# Database settings
db_name       = "learning_platform"
db_user       = "app_user"
db_instance_tier = "db-g1-small"
db_version    = "POSTGRES_14"

# Redis settings
redis_name    = "learning-platform-redis"
redis_tier    = "BASIC"

# Storage settings
bucket_name   = "learning-materials"

# Cloud Run settings
frontend_service_name = "learning-platform-frontend"
backend_service_name  = "learning-platform-backend"
min_instances = 0
max_instances = 10
concurrency   = 80

# IAM settings
cloud_run_service_account_id  = "cloud-run-sa"
cloud_build_service_account_id = "cloud-build-sa"

# Cloud Build settings
github_owner  = "your-github-username"
github_repo   = "your-repo-name"
branch_name   = "master"

# Load Balancer settings
enable_cdn    = false

# Monitoring settings
error_rate_threshold = 5
notification_channels = []
