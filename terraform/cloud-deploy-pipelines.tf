# copied from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/clouddeploy_delivery_pipeline

resource "google_clouddeploy_delivery_pipeline" "primary" {
  location = var.gcp_region      
  name     = "${var.terraform_prefix}pipeline-app01" # just a test for now
  project = "${var.project_id}"

  annotations = {
    "${var.terraform_prefix}my_first_annotation" = "example-annotation-1"
    #my_second_annotation = "example-annotation-2"
    "${var.terraform_prefix}coder" = "ricc@"
    "${var.terraform_prefix}created_by" = "Riccardo Carlesso"
    "${var.terraform_prefix}github_repo" = var.code_repo
  }

  description = "[Created with Terraform] basic description"

  labels = {
    my_first_label = "example-label-1"
    my_second_label = "example-label-2"
     "${var.terraform_prefix}ricc_stage" = "prova123" 
  }


  serial_pipeline {
    stages {
      profiles  = []
      target_id = "${var.terraform_prefix}dev"
    }
    stages {
      #profiles  = ["example-profile-one", "example-profile-two"]
      target_id = "${var.terraform_prefix}staging"
    }
    stages {
      profiles  = []
      target_id = "${var.terraform_prefix}canary"
    }
    stages {
      profiles  = []
      target_id = "${var.terraform_prefix}prod"
    }
  }
}
