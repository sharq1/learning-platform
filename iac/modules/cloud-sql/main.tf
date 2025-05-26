# Cloud SQL Module - Creates PostgreSQL instance, database and user

resource "google_sql_database_instance" "instance" {
  name             = "learning-platform-db-instance"
  database_version = var.db_version
  region           = var.region
  
  settings {
    tier              = var.db_instance_tier
    availability_type = "REGIONAL"  # Multi-AZ for high availability
    
    backup_configuration {
      enabled            = true
      binary_log_enabled = false
      start_time         = "02:00"  # UTC time
      location           = var.region
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
    
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }
    
    maintenance_window {
      day          = 7  # Sunday
      hour         = 3  # 3 AM UTC
      update_track = "stable"
    }
    
    database_flags {
      name  = "max_connections"
      value = "100"
    }
    
    # Enable auto-pausing for cost optimization
    activation_policy = "ALWAYS"
  }
  
  deletion_protection = true  # Prevent accidental deletion
  
  lifecycle {
    prevent_destroy = true
  }
}

# Create database
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.instance.name
  charset  = "UTF8"
  
  depends_on = [google_sql_database_instance.instance]
}

# Create user
resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = var.db_password
  
  depends_on = [google_sql_database_instance.instance]
}
