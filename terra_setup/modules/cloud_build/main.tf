resource "google_project_iam_binding" "cloud_build_service_account_user" {
  project     = "${var.project}"
  role = "roles/iam.serviceAccountUser"
  members = [
      "serviceAccount:${var.proj_number}@cloudbuild.gserviceaccount.com"
  ]
}
resource "google_project_iam_binding" "cloud_build_run_admin" {
  project     = "${var.project}"
  role = "roles/run.admin"
  members = [
      "serviceAccount:${var.proj_number}@cloudbuild.gserviceaccount.com"
  ]
}

#resource "google_project_service" "api_compute" {
#  project = "${var.project}"
#  service = "compute.googleapis.com"

#  disable_dependent_services = false
#}

#resource "google_project_service" "api_appengine" {
#  project = "${var.project}"
#  service = "appengine.googleapis.com"

#  disable_dependent_services = false
#}

data "google_compute_default_service_account" "default" {
}

resource "google_project_iam_binding" "cloud_build_appengine_admin" {
  project     = "${var.project}"
  role = "roles/appengine.appAdmin"
  members = [
      "serviceAccount:${var.proj_number}@cloudbuild.gserviceaccount.com"
  ]
}

resource "google_service_account_iam_member" "cloudbuild_cloudrun_service" {
  service_account_id = data.google_compute_default_service_account.default.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.proj_number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_binding" "cloud_build_cloud_function_developer" {
  project     = "${var.project}"
  role = "roles/cloudfunctions.developer"
  members = [
      "serviceAccount:${var.proj_number}@cloudbuild.gserviceaccount.com"
  ]
}

resource "google_cloudbuild_trigger" "func_calc_update" {
  name = "func-calc-update"
  
  trigger_template {
    branch_name = "master"
    repo_name   = "${var.repo}"
  }

  filename = "interface/deploy_calc.yaml"
}

resource "google_cloudbuild_trigger" "func_refresh_update" {
  name = "func-refresh-update"
  
  trigger_template {
    branch_name = "master"
    repo_name   = "${var.repo}"
  }

  filename = "interface/deploy_refresh.yaml"
}

resource "google_cloudbuild_trigger" "func_unload_update" {
  name = "func-unload-update"
  
  trigger_template {
    branch_name = "master"
    repo_name   = "${var.repo}"
  }

  filename = "interface/deploy_unload.yaml"
}

resource "google_cloudbuild_trigger" "viz_v02_update" {
  name = "update-viz02"
  
  trigger_template {
    branch_name = "master"
    repo_name   = "${var.repo}"
  }

  filename = "viz_v02/cloudbuild_cicd.yaml"
}


resource "google_cloud_run_service" "viz_v02_create" {
  name     = "service-preview"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/image_preview"
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.viz_v02_create.location
  project     = google_cloud_run_service.viz_v02_create.project
  service     = google_cloud_run_service.viz_v02_create.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloudbuild_trigger" "viz_v01_update" {
  name = "update-viz01"
  
  trigger_template {
    branch_name = "master"
    repo_name   = "${var.repo}"
  }

  filename = "viz/cloudbuild.yaml"
}
