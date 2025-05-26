# Storage Module - Variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for resources deployment"
  type        = string
}

variable "bucket_name" {
  description = "Name of the Cloud Storage bucket for learning materials"
  type        = string
}
