# Load Balancer Module - Outputs

output "load_balancer_ip" {
  description = "The IP address of the load balancer"
  value       = google_compute_global_address.default.address
}

output "load_balancer_url" {
  description = "The URL of the load balancer"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${google_compute_global_address.default.address}"
}

output "api_neg_id" {
  description = "The ID of the API serverless NEG"
  value       = google_compute_region_network_endpoint_group.api_neg.id
}

# Keep these for backward compatibility but mark them as deprecated
output "frontend_neg_id" {
  description = "[DEPRECATED] Use api_neg_id instead. The ID of the API serverless NEG"
  value       = google_compute_region_network_endpoint_group.api_neg.id
}

output "backend_neg_id" {
  description = "[DEPRECATED] Use api_neg_id instead. The ID of the API serverless NEG"
  value       = google_compute_region_network_endpoint_group.api_neg.id
}
