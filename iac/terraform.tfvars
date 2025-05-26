# Sample terraform.tfvars with default values
# Update these values according to your GCP environment

# Project settings
project_id    = "learning-platform-461008"
region        = "us-central1"
network_name  = "learning-platform-network"

# Database settings
db_name       = "learning_platform"
db_user       = "app_user"
db_instance_tier = "db-f1-micro"
db_version    = "POSTGRES_17"

# Redis settings
redis_name    = "learning-platform-redis"
redis_tier    = "BASIC"

# Storage settings
bucket_name   = "learning-platform-materials"

# Cloud Run settings
# service_name is defined in variables.tf with a default value of "learning-platform-api"
frontend_service_name = "" # Left empty, service_name is used instead
backend_service_name = ""  # Left empty, service_name is used instead
min_instances = 1
max_instances = 2
concurrency   = 5

# IAM settings
cloud_run_service_account_id  = "cloud-run-sa"
cloud_build_service_account_id = "cloud-build-sa"

# Cloud Build settings
github_owner  = "sharq1"
github_repo   = "learning-platform"
branch_name   = "master"

# Load Balancer settings
enable_cdn    = false

# Monitoring settings
error_rate_threshold = 5
notification_channels = []
