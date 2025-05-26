# Load Balancer Module - Creates a global HTTP Load Balancer with Cloud Run backend services

# Create global external IP address
resource "google_compute_global_address" "default" {
  name = "learning-platform-lb-ip"
}

# Create SSL certificate for HTTPS
resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta
  name     = "learning-platform-ssl-cert"

  managed {
    domains = [var.domain_name]
  }
  
  # Only create the certificate if a domain name is provided
  count = var.domain_name != "" ? 1 : 0
}

# Create a serverless NEG for the frontend service
resource "google_compute_region_network_endpoint_group" "frontend_neg" {
  name                  = "frontend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  
  cloud_run {
    service = var.frontend_service_name
  }
}

# Create a serverless NEG for the backend service
resource "google_compute_region_network_endpoint_group" "backend_neg" {
  name                  = "backend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  
  cloud_run {
    service = var.backend_service_name
  }
}

# Create backend service for frontend
resource "google_compute_backend_service" "frontend" {
  name                  = "frontend-backend-service"
  protocol              = "HTTP"
  timeout_sec           = 30
  enable_cdn            = var.enable_cdn
  load_balancing_scheme = "EXTERNAL_MANAGED"
  
  backend {
    group = google_compute_region_network_endpoint_group.frontend_neg.id
  }
  
  # CDN configuration if enabled
  dynamic "cdn_policy" {
    for_each = var.enable_cdn ? [1] : []
    content {
      cache_mode  = "CACHE_ALL_STATIC"
      client_ttl  = 3600
      default_ttl = 3600
      max_ttl     = 86400
      
      negative_caching = true
      signed_url_cache_max_age_sec = 7200
    }
  }
}

# Create backend service for backend API
resource "google_compute_backend_service" "backend" {
  name                  = "backend-backend-service"
  protocol              = "HTTP"
  timeout_sec           = 30
  enable_cdn            = false  # No CDN for API calls
  load_balancing_scheme = "EXTERNAL_MANAGED"
  
  backend {
    group = google_compute_region_network_endpoint_group.backend_neg.id
  }
}

# URL map to route requests to the appropriate backend
resource "google_compute_url_map" "url_map" {
  name            = "learning-platform-url-map"
  default_service = google_compute_backend_service.frontend.id
  
  host_rule {
    hosts        = [var.domain_name != "" ? var.domain_name : "*"]
    path_matcher = "paths"
  }
  
  path_matcher {
    name            = "paths"
    default_service = google_compute_backend_service.frontend.id
    
    # Route API requests to the backend service
    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.backend.id
    }
  }
}

# HTTP proxy
resource "google_compute_target_http_proxy" "http" {
  name    = "learning-platform-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

# HTTPS proxy (if domain and certificate are provided)
resource "google_compute_target_https_proxy" "https" {
  name             = "learning-platform-https-proxy"
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default[0].id]
  
  count = var.domain_name != "" ? 1 : 0
}

# HTTP forwarding rule
resource "google_compute_global_forwarding_rule" "http" {
  name                  = "learning-platform-http-rule"
  target                = google_compute_target_http_proxy.http.id
  port_range            = "80"
  ip_address            = google_compute_global_address.default.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# HTTPS forwarding rule (if domain and certificate are provided)
resource "google_compute_global_forwarding_rule" "https" {
  name                  = "learning-platform-https-rule"
  target                = google_compute_target_https_proxy.https[0].id
  port_range            = "443"
  ip_address            = google_compute_global_address.default.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  
  count = var.domain_name != "" ? 1 : 0
}
