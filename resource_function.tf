# thanks to https://towardsdatascience.com/deploy-cloud-functions-on-gcp-with-terraform-111a1c4a9a88

# Enable Cloud Functions API
resource "google_project_service" "cloudfunctions" {
  project = var.gcp_project_id
  service = "cloudfunctions.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable Cloud Build API (required for Functions)
resource "google_project_service" "cloudbuild" {
  project = var.gcp_project_id
  service = "cloudbuild.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "src"
  output_path = "/tmp/function.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "zip" {
  source       = data.archive_file.source.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "src-${data.archive_file.source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "qrcode-generator" {
  project = var.gcp_project_id
  name    = "qrcode-generator"
  runtime = "python39"
  region  = var.google_region

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.zip.name
  trigger_http          = true
  entry_point           = "make_qrcode"
  service_account_email = google_service_account.qrcode_function.email

  environment_variables = {
    BUCKET_NAME = google_storage_bucket.qrcodes-bucket.name
  }

  depends_on = [
    google_project_service.cloudfunctions,
    google_project_service.cloudbuild
  ]
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_binding" "public_access" {
  project = google_cloudfunctions_function.qrcode-generator.project
  region = google_cloudfunctions_function.qrcode-generator.region
  cloud_function = google_cloudfunctions_function.qrcode-generator.name
  role = "roles/cloudfunctions.invoker"
  members = [
    "allUsers",
  ]
}

# service account the function will run as
resource "google_service_account" "qrcode_function" {
  project      = var.gcp_project_id
  account_id   = "qrcode-function"
  display_name = "Service Account for QR Code Cloud Function"
}

# grant the function write access to qrcode bucket
resource "google_storage_bucket_access_control" "qrcode_function_iam" {
  bucket = google_storage_bucket.qrcodes-bucket.name
  role   = "WRITER"
  entity = "user-${google_service_account.qrcode_function.email}"
}