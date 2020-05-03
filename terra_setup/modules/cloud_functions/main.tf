resource "google_pubsub_topic" "pubsub_calc" {
  name = "calc"
}

resource "google_pubsub_topic" "pubsub_refresh" {
  name = "refresh"
}

resource "google_pubsub_topic" "pubsub_unload" {
  name = "unload"
}

# resource "google_project_service" "api_cloudfunctions" {
#  project = "${var.project}"
#  service = "cloudfunctions.googleapis.com"

#  disable_dependent_services = false
#}


#resource "google_project_service" "api_sheets" {
#  project = "${var.project}"
#  service = "sheets.googleapis.com"

#  disable_dependent_services = false
#}

resource "google_cloudfunctions_function" "function_calc" {
  name        = "ui-calc"
  description = "Function to take user inputs and perform calculations"
  runtime     = "python37"
  region = "us-central1"

  available_memory_mb   = 256
  entry_point           = "calc"
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.pubsub_calc.name
  }

  service_account_email = "ui-big-query-service@${var.project}.iam.gserviceaccount.com"

  source_repository {
    url = join("",["https://source.developers.google.com/projects/","${var.project}","/repos/","${var.repo}","/moveable-aliases/master/paths/interface"])
  }
}

resource "google_cloudfunctions_function" "function_refresh" {
  name        = "ui-refresh"
  description = "Function load new source data on user request"
  runtime     = "python37"
  region = "us-central1"

  available_memory_mb   = 256
  entry_point           = "refresh"
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.pubsub_refresh.name
  }

  source_repository {
    url = join("",["https://source.developers.google.com/projects/","${var.project}","/repos/","${var.repo}","/moveable-aliases/master/paths/interface"])
  }
}

resource "google_cloudfunctions_function" "function_unload" {
  name        = "ui-unload"
  description = "Function unload refreshed data from source_supply table. To reset demo to starting state"
  runtime     = "python37"
  region = "us-central1"

  available_memory_mb   = 256
  entry_point           = "unload"
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.pubsub_unload.name
  }

  source_repository {
    url = join("",["https://source.developers.google.com/projects/","${var.project}","/repos/","${var.repo}","/moveable-aliases/master/paths/interface"])
  }
}
