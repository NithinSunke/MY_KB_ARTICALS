terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  region              = var.region
  config_file_profile = var.profile
}

resource "oci_bastion_bastion" "my_bastion" {
  bastion_type     = "STANDARD"
  compartment_id   = var.compartment_id
  target_subnet_id = var.subnet_id

  name                         = var.bastion_name
  client_cidr_block_allow_list = ["139.5.250.69/32"] # Replace with your IP for security
  max_session_ttl_in_seconds   = 10800         # 3 hours

  freeform_tags = {
    "CreatedBy" = "Terraform"
  }
}