# # copied from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/clouddeploy_target

resource "google_clouddeploy_target" "dev" {
  location = var.gcp_region # "us-west1"
  name     = "${var.terraform_prefix}dev"

  annotations = {
    my_first_annotation = "example-annotation-1"
    my_second_annotation = "example-annotation-2"
  }

  description = "[Created with Terraform] Pointing to CICD dev cluster"

  gke {
    cluster = "projects/${var.project_id}/locations/${var.gcp_region}/clusters/cicd-dev"
  }

  labels = {
    my_first_label = "gke"
    my_second_label = "example-label-2"
  }

  project          =  "${var.project_id}"
  require_approval = false
}

resource "google_clouddeploy_target" "staging" {
  location = var.gcp_region # "us-west1"
  name     = "${var.terraform_prefix}staging"

  annotations = {
    my_first_annotation = "example-annotation-1"
    my_second_annotation = "example-annotation-2"
  }

  description = "[Created with Terraform] Pointing to CICD dev cluster"

  gke {
    cluster = "projects/${var.project_id}/locations/${var.gcp_region}/clusters/cicd-dev"
  }

  labels = {
    my_first_label = "gke"
    my_second_label = "example-label-2"
  }

  project          =  "${var.project_id}"
  require_approval = false
}
