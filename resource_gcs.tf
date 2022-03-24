resource "google_storage_bucket" "function_bucket" {
  name     = "${var.gcp_project_id}-function"
  project  = var.gcp_project_id
  location = var.gcs_location
}

resource "google_storage_bucket" "qrcodes-bucket" {
  name     = "${var.gcp_project_id}-qrcodes"
  project  = var.gcp_project_id
  location = var.gcs_location
}

resource "google_storage_bucket_iam_binding" "public_access" {
  bucket = google_storage_bucket.qrcodes-bucket.name
  role = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}