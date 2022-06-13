provider "google" {
  project     = var.project_id # eg, "cicd-platinum-test001"
  credentials = var.gcp_credentials_json
  gcp_region      = var.gcp_region
}

