resource "google_pubsub_topic" "document_changed" {
  name = "document-changed"
  depends_on = [
    google_project_service.gcp_apis
  ]
}

resource "google_pubsub_topic" "processing_finished" {
  name = "processing-finished"
  depends_on = [
    google_project_service.gcp_apis
  ]
}

resource "google_pubsub_topic" "notification_needed" {
  name = "notification-needed"
  depends_on = [
    google_project_service.gcp_apis
  ]
}
