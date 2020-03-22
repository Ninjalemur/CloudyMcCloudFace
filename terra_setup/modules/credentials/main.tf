
resource "google_service_account" "sa" {
  account_id   = "ui-big-query-service"
  display_name = "service account to access BigQuery"
}

resource "google_project_iam_binding" "bq-data-editors" {
  project     = "${var.project}"
  role = "roles/bigquery.dataEditor"
  members = [
      "serviceAccount:ui-big-query-service@${var.project}.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "bq-job-users" {
  project     = "${var.project}"
  role = "roles/bigquery.jobUser"
  members = [
      "serviceAccount:ui-big-query-service@${var.project}.iam.gserviceaccount.com"
  ]
}