resource "google_clouddeploy_target" "primary" {
  location = "us-west1"
  name     = "target"

  annotations = {
    my_first_annotation = "example-annotation-1"

    my_second_annotation = "example-annotation-2"
  }

  description = "basic description"

  gke {
    cluster = "projects/my-project-name/locations/us-west1/clusters/example-cluster-name"
  }

  labels = {
    my_first_label = "example-label-1"

    my_second_label = "example-label-2"
  }

  project          = "my-project-name"
  require_approval = false
}

