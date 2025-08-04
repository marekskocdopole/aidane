variable "project_id" {
  description = "The GCP project ID to deploy resources to."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources to."
  type        = string
  default     = "europe-west3"
}

variable "raw_documents_bucket_name" {
  description = "The name of the GCS bucket for raw documents."
  type        = string
}

variable "processed_documents_bucket_name" {
  description = "The name of the GCS bucket for processed documents."
  type        = string
} 