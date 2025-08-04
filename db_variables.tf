variable "db_password" {
  description = "The password for the root user of the Cloud SQL instance."
  type        = string
  sensitive   = true
}
