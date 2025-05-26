# Storage Module - Creates Cloud Storage bucket with versioning and lifecycle rules

resource "google_storage_bucket" "learning_materials" {
  name          = "${var.project_id}-${var.bucket_name}"
  location      = var.region
  force_destroy = false
  
  # Enable versioning for content safety
  versioning {
    enabled = true
  }
  
  # Lifecycle rules for auto-tiering
  lifecycle_rule {
    condition {
      age = 30  # 30 days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 90  # 90 days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 365  # 1 year
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }
  
  # Object versioning - keeping only 3 versions
  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
  
  # Uniform bucket-level access
  uniform_bucket_level_access = true
  
  lifecycle {
    prevent_destroy = true
  }
}
