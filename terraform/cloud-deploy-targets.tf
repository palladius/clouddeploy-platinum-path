/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# # copied from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/clouddeploy_target

resource "google_clouddeploy_target" "dev" {
  location = var.gcp_region # "us-west1"
  name     = "${var.terraform_prefix}dev"

  annotations = {
    "${var.terraform_prefix}my_first_annotation" = "example-annotation-1"
    "${var.terraform_prefix}my_second_annotation" = "example-annotation-2"
    "${var.terraform_prefix}ricc_explanation" = "dev-target-in-dev-cluster"
    "${var.terraform_prefix}coder" = "ricc@"

  }

  description = "[Created with Terraform] Pointing to CICD dev cluster"

  gke {
    cluster = "projects/${var.project_id}/locations/${var.gcp_region}/clusters/cicd-dev"
  }

  labels = {
    my_first_label = "gke"
    ricc_explanation = "dev-target-in-dev"
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
    ricc_explanation = "staging-target-in-dev-cluster"
  }

  project          =  "${var.project_id}"
  require_approval = false
}



resource "google_clouddeploy_target" "canary" {
  location = var.gcp_region 
  name     = "${var.terraform_prefix}canary"

  annotations = {
    my_first_annotation = "example-annotation-1"
    my_second_annotation = "example-annotation-2"
  }

  description = "[Created with Terraform] Pointing to CICD dev cluster"

  gke {
    cluster = "projects/${var.project_id}/locations/${var.gcp_region}/clusters/cicd-canary"
  }

  labels = {
    my_first_label = "gke"
    ricc_explanation = "canary-target-in-canary-cluster"
  }

  project          =  "${var.project_id}"
  require_approval = false
}



resource "google_clouddeploy_target" "prod" {
  location = var.gcp_region # "us-west1"
  name     = "${var.terraform_prefix}prod"

  annotations = {
    my_first_annotation = "example-annotation-1"
    my_second_annotation = "example-annotation-2"
  }

  description = "[Created with Terraform] Pointing to CICD prod cluster"

  gke {
    cluster = "projects/${var.project_id}/locations/${var.gcp_region}/clusters/cicd-prod"
  }

  labels = {
    my_first_label = "gke"
    ricc_explanation = "prod-target-in-prod-cluster-with-approval"
  }

  project          =  "${var.project_id}"
  require_approval = true
}
