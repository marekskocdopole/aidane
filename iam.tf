# Servisní účet, pod kterým poběží naše Cloud Functions
resource "google_service_account" "data_processor" {
  account_id   = "data-processor-sa"
  display_name = "Data Processor Service Account"
}

# Oprávnění pro náš servisní účet, aby mohl číst/psát do GCS a Pub/Sub
resource "google_project_iam_member" "data_processor_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = google_service_account.data_processor.member
}

# --- KLÍČOVÁ OPRÁVNĚNÍ PRO NASAZENÍ ---
# Účet, který spouští Terraform, potřebuje oprávnění "jednat jako"
# servisní účty, které přiřazuje funkcím.

# 1. Oprávnění jednat jako náš vlastní 'data-processor-sa' účet.
resource "google_service_account_iam_member" "executor_can_act_as_processor" {
  service_account_id = google_service_account.data_processor.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:terraform-executor@dane-ai-467709.iam.gserviceaccount.com"
}

# 2. Oprávnění jednat jako výchozí Compute Engine účet, který používá
# proces nasazování Cloud Functions v zákulisí.
resource "google_service_account_iam_member" "executor_can_act_as_compute" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/675508348269-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:terraform-executor@dane-ai-467709.iam.gserviceaccount.com"
}
