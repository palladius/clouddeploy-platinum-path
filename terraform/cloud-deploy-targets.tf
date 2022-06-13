# # copied from https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/clouddeploy_target

# resource "google_clouddeploy_target" "primary" {
#   location = "us-west1"
#   name     = "target"

#   annotations = {
#     my_first_annotation = "example-annotation-1"
#     my_second_annotation = "example-annotation-2"
#   }

#   description = "basic description"

#   gke {
#     cluster = "projects/${var.project_id}/locations/us-west1/clusters/example-cluster-name"
#   }

#   labels = {
#     my_first_label = "example-label-1"

#     my_second_label = "example-label-2"
#   }

#   project          =  "${var.project_id}"
#   require_approval = false
# }

