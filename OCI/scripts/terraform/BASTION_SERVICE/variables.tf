#variable for region
variable "region" {
  description = "OCI region to deploy the compute instance"
  type        = string
  default     = "me-jeddah-1"
}

#variable for config_file_profile
variable "profile" {
  description = "OCI config file profile to use for authentication"
  type        = string
  default     = "DEFAULT"
}
variable "compartment_id" {
  description = "The OCID of the compartment where the bastion will be created"
  type        = string
  default     = "ocid1.compartment.oc1..aaaaaaaa3bsnwqvif5r4gxzd6o5kd46jiwfdxly4v7pswkmvxkqoa34u4esa"
}
variable "subnet_id" {
  description = "The OCID of the subnet where the bastion will be created"
  type        = string
  default     = "ocid1.subnet.oc1.me-jeddah-1.aaaaaaaansdp7rx5sgl4j5anw6em6ttgijccvm7wh43e24xjkskhnrcozzma"
}
variable "bastion_name" {
  description = "The name of the bastion"
  type        = string
  default     = "scslabs-mssql-bastion"
}