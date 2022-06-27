# * provider.google: version = "~> 3.65"
# * provider.google-beta: version = "~> 3.65"

# provider "google-beta" {
#   version = "~> 4.0.0"

#   project     = var.project_id # eg, "cicd-platinum-test001"
#   credentials = var.gcp_credentials_json
#   region      = var.gcp_region
# }

terraform {
  # ... other configuration ...
  required_providers {
    google = {
#      version = "~> 4.24.0"
      version = ">= 4.24.0"
    }
  }
}

# doesnt support CD! 
provider "google" {
  project     = var.project_id # eg, "cicd-platinum-test001"
  credentials = var.gcp_credentials_json
  region      = var.gcp_region
}

