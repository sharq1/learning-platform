# VPC Module - Creates VPC network, subnet and Serverless VPC Access connector

# Enable Service Networking API
resource "google_project_service" "servicenetworking" {
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

# Create VPC network
resource "google_compute_network" "network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  description             = "Main network for the learning platform"
  
  lifecycle {
    prevent_destroy = true
  }
}

# Create subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.network.id
  
  private_ip_google_access = true
  
  lifecycle {
    prevent_destroy = true
  }
}

# Reserve IP range for private services (Cloud SQL and Redis)
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.network_name}-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.network.id
}

# Create the private connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  
  depends_on = [google_project_service.servicenetworking]
}

# Create Serverless VPC Access connector
resource "google_vpc_access_connector" "connector" {
  name          = "sl-vpc-conn-v2"
  region        = var.region
  network       = google_compute_network.network.name
  ip_cidr_range = var.connector_cidr
  
  # Standard-1 machine type for connector
  machine_type       = "e2-micro"
  min_instances = 2
  max_instances = 10
  
  depends_on = [
    google_compute_network.network,
    google_compute_subnetwork.subnet
  ]
}
