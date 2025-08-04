# --- ZDROJOVÉ KÓDY PRO FUNKCE ---
# Krok 1: Vytvoří lokální zip soubory z kódu ve složkách.
data "archive_file" "scraper_source" {
  type        = "zip"
  source_dir  = "${path.module}/functions/scraper"
  output_path = "${path.module}/scraper.zip"
}

data "archive_file" "processor_source" {
  type        = "zip"
  source_dir  = "${path.module}/functions/processor"
  output_path = "${path.module}/processor.zip"
}

# --- NAHRÁNÍ ZDROJOVÝCH KÓDŮ DO GCS ---
# Krok 2: Nahraje lokální zip soubory do GCS bucketu. Toto je ten chybějící krok.
resource "google_storage_bucket_object" "scraper_archive" {
  name   = "source/scraper-${data.archive_file.scraper_source.output_md5}.zip"
  bucket = google_storage_bucket.raw_documents.name
  source = data.archive_file.scraper_source.output_path
}

resource "google_storage_bucket_object" "processor_archive" {
  name   = "source/processor-${data.archive_file.processor_source.output_md5}.zip"
  bucket = google_storage_bucket.raw_documents.name
  source = data.archive_file.processor_source.output_path
}

# --- FUNKCE 1: SCRAPER ---
# Krok 3: Vytvoří funkci a řekne jí, aby si vzala kód z nahraného objektu v GCS.
resource "google_cloudfunctions_function" "scraper" {
  name                  = "scraper-function"
  runtime               = "python39"
  project               = var.project_id
  region                = var.region
  source_archive_bucket = google_storage_bucket.raw_documents.name
  source_archive_object = google_storage_bucket_object.scraper_archive.name # Odkaz na nahraný objekt
  entry_point           = "process_document_change"
  service_account_email = google_service_account.data_processor.email

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.document_changed.name
  }

  depends_on = [
    google_service_account_iam_member.executor_can_act_as_processor,
    google_service_account_iam_member.executor_can_act_as_compute
  ]
}

# --- FUNKCE 2: PROCESSOR ---
resource "google_cloudfunctions_function" "processor" {
  name                  = "processor-function"
  runtime               = "python39"
  project               = var.project_id
  region                = var.region
  source_archive_bucket = google_storage_bucket.raw_documents.name
  source_archive_object = google_storage_bucket_object.processor_archive.name # Odkaz na nahraný objekt
  entry_point           = "process_raw_document"
  service_account_email = google_service_account.data_processor.email

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.raw_documents.name
  }

  depends_on = [
    google_service_account_iam_member.executor_can_act_as_processor,
    google_service_account_iam_member.executor_can_act_as_compute
  ]
}
