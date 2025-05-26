# outputs.tf - Output values for Learning Platform Infrastructure

output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = module.vpc.network_name
}

output "vpc_subnet_name" {
  description = "The name of the VPC subnet"
  value       = module.vpc.subnet_name
}

output "vpc_connector_id" {
  description = "The ID of the Serverless VPC Access connector"
  value       = module.vpc.connector_id
}

output "cloud_sql_instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = module.cloud_sql.instance_name
}

output "cloud_sql_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = module.cloud_sql.connection_name
}

output "cloud_sql_ip_address" {
  description = "The private IP address of the Cloud SQL instance"
  value       = module.cloud_sql.private_ip_address
}

output "redis_instance_id" {
  description = "The ID of the Redis instance"
  value       = module.redis.instance_id
}

output "redis_host" {
  description = "The host of the Redis instance"
  value       = module.redis.redis_host
}

output "storage_bucket_url" {
  description = "The URL of the storage bucket"
  value       = module.storage.bucket_url
}

output "cloud_run_api_url" {
  description = "The URL of the FastAPI Cloud Run service"
  value       = module.cloud_run.api_url
}

output "cloud_run_service_account_email" {
  description = "The email of the Cloud Run service account"
  value       = module.iam.cloud_run_service_account_email
}

output "cloud_build_service_account_email" {
  description = "The email of the Cloud Build service account"
  value       = module.iam.cloud_build_service_account_email
}

output "load_balancer_ip_address" {
  description = "The IP address of the load balancer"
  value       = module.load_balancer.load_balancer_ip
}

output "load_balancer_url" {
  description = "The URL of the load balancer"
  value       = module.load_balancer.load_balancer_url
}
