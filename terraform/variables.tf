##################################################################################
# Note: this file is a symlink from ../shared/ directory!!! Alla faccia del DRY!
##################################################################################

# variable "organization_id" {
#   type        = string
#   description = "Your Org Id, e.g. 911748599584 (see https://screenshot.googleplex.com/aDcKdit7JaN)"
#   #default = "911748599584" carlessos.org
# }

# variable "organization_domain" {
#   type        = string
#   description = "Your Org Domain, e.g. 'example.com'"
# }

variable "project_id" {
  type        = string
  description = "Your Project ID, e.g. 'pincopallo'"
}

variable "gcp_region" {
  type        = string
  description = "Your GCP Region, e.g. 'europe-west6' (Zurich)"
  default     = "europe-west6" # Zurich
}

variable "gcp_zone" {
  type        = string
  description = "Your GCP Zone, e.g. 'europe-west6-b' (needs to be within the specified region!)"
  default     = "europe-west6-b" # Zurich-B
}



variable "baid" {
  type        = string
  description = "Your BIlling Account Id, 18 hexes (e.g.= 0014BA-601817-36A1AA)"
  default     = "0014BA-601817-36A1AA"
}


# variable "whitelist_ipv6s" {
#   type        = list(string)
#   description = "To which IPv6 IPs to open our services (not used yet)"
#   default = [
#     "2a00:79e0:48:202:1998:7166:e2da:fa17", # Derek ephemeral IP
#   ]
# }

variable "gcp_credentials_json" {
  type = string
}

# variable "terraform_state_bucket" {
#   type = string
#   default = "ricc-terraform-states" # could be the same for all my repos - no biggie. PREFIX needs to change
# } 

variable "terraform_prefix" {
  type = string
  default = "" # empty string 
  description = "names resources 'PREFIX-BLAH' TODO be implemented yet"
}

#variable "terraform_state_prefix" {
#  type = string
#  default = "_INUTILE_" you cant parametrize TF state :/
#} 

# variable "lots_of_folders" {
#   description = "Map of folders from a website" #https://www.hashicorp.com/blog/hashicorp-terraform-0-12-preview-for-and-for-each/
#   default = {
#     "tizio"     = 1
#     "caio"      = 2
#     "sempronio" = 3
#   }
# }

