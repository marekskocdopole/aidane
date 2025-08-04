resource "google_storage_bucket" "raw_documents" {
  name     = var.raw_documents_bucket_name
  location = var.region

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "processed_documents" {
  name     = var.processed_documents_bucket_name
  location = var.region

  versioning {
    enabled = true
  }
} 