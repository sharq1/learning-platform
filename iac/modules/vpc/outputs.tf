# VPC Module - Outputs

output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.network.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.network.name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "connector_id" {
  description = "The ID of the Serverless VPC Access connector"
  value       = google_vpc_access_connector.connector.self_link
}

output "connector_resource" {
  description = "The Serverless VPC Access connector resource object."
  value       = google_vpc_access_connector.connector
}

output "private_service_networking_connection_resource" {
  description = "The private service networking connection resource object."
  value       = google_service_networking_connection.private_vpc_connection
}

output "connector_name" {
  description = "The name of the Serverless VPC Access connector"
  value       = google_vpc_access_connector.connector.name
}
