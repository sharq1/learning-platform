# VPC Module - Creates VPC network, subnet and Serverless VPC Access connector

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

# Create Serverless VPC Access connector
resource "google_vpc_access_connector" "connector" {
  name          = "serverless-vpc-connector"
  region        = var.region
  network       = google_compute_network.network.name
  ip_cidr_range = var.connector_cidr
  
  # Standard-1 machine type for connector
  machine_type = "e2-standard-4"
  min_instances = 2
  max_instances = 10
  
  depends_on = [
    google_compute_network.network,
    google_compute_subnetwork.subnet
  ]
}
