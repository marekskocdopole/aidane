resource "google_sql_database_instance" "default" {
  name             = "postgres-instance"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-custom-1-3840"
  }

  root_password = var.db_password

  depends_on = [
    google_project_service.gcp_apis
  ]
}
