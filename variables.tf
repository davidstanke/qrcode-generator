variable "gcp_project_id" {
  description = "project ID to provision resources into (example: [\"project_1\",\"project_2\"])"
  type        = string
}

variable "google_region" {
  description = "GCP region in which to provision resources (example: \"us-central1\")"
  type        = string
}

variable "gcs_location" {
  description = "location for GCS bucket (example: \"US\")"
  type        = string
}