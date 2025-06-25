# This file contains the variables used in the VCN module.
variable "config_file_profile" {
  description = "profile name"
  type        = string
  default     = "DR"
}

variable "region" {
  description = "OCI region"
  type        = string
  default     = "me-riyadh-1"
}

variable "compartment_id" {
  description = "Compartment OCID"
  type        = string
  default     = "ocid1.compartment.oc1..aaaaaaaa3bsnwqvif5r4gxzd6o5kd46jiwfdxly4v7pswkmvxkqoa34u4esa"
}

variable "my_ip" {
  description = "Your public IP address"
  type        = string
  default     = "139.5.250.69/32"
}

variable "vcn_name" {
  description = "Name of the VCN"
  type        = string
  default     = "scslabsr"
}
variable "cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "12.0.0.0/16"
}

variable "public_cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "12.0.1.0/24"
}

variable "oracle_cidr_block" {
  description = "CIDR block for the Oracle Subnet"
  type        = string
  default     = "12.0.2.0/24"
}
variable "mssql_cidr_block" {
  description = "CIDR block for the MSSQL Subnet"
  type        = string
  default     = "12.0.3.0/24"
}

variable "dns_label" {
  description = "DNS label for the VCN"
  type        = string
  default     = "scslabs"
}
variable "display_name" {
  description = "Display name for the VCN"
  type        = string
  default     = "scslabsr"
}

#variable for internet gateway
variable "igw_name" {
  description = "Name of the Internet Gateway"
  type        = string
  default     = "scslabsr_igw"
}

#variable for NAT gateway
variable "nat_gw_name" {
  description = "Name of the NAT Gateway"
  type        = string
  default     = "scslabsr_nat_gw"
}
#variable for public route table
variable "public_rt_name" {
  description = "Name of the Public Route Table"
  type        = string
  default     = "scslabsr_public_rt"
}
#variable for Oracle route table
variable "oracle_rt_name" {
  description = "Name of the Oracle Route Table"
  type        = string
  default     = "scslabsr_oracle_rt"
}
#variable for MSSQL route table
variable "mssql_rt_name" {
  description = "Name of the MSSQL Route Table"
  type        = string
  default     = "scslabsr_mssql_rt"
}
#variable for service gateway destination
variable "service_gw_dest" {
  description = "Name of the Service Gateway"
  type        = string
}

#variable public subnet display name
variable "public_subnet_name" {
  description = "Name of the Public Subnet"
  type        = string
  default     = "scslabsr_pub"
}
#variable oracle subnet display name
variable "oracle_subnet_name" {
  description = "Name of the Oracle Subnet"
  type        = string
  default     = "scslabsr_orcl"
}
#variable mssql subnet display name
variable "mssql_subnet_name" {
  description = "Name of the MSSQL Subnet"
  type        = string
  default     = "scslabsr_mssql"
}
#variable for public subnet dns label
variable "public_subnet_dns_label" {
  description = "DNS label for the Public Subnet"
  type        = string
  default     = "scslabsrpub"
}
#variable for oracle subnet dns label
variable "oracle_subnet_dns_label" {
  description = "DNS label for the Oracle Subnet"
  type        = string
  default     = "scslabsrorcl"
}

#variable for mssql subnet dns label
variable "mssql_subnet_dns_label" {
  description = "DNS label for the MSSQL Subnet"
  type        = string
  default     = "scslabsrmssql"
}

#variable for public security list name
variable "public_sl_name" {
  description = "Name of the Public Security List"
  type        = string
  default     = "scslabsr_public_sl"
}
#variable for oracle security list name
variable "oracle_sl_name" {
  description = "Name of the Oracle Security List"
  type        = string
  default     = "scslabsr_oracle_sl"
}
#variable for mssql security list name
variable "mssql_sl_name" {
  description = "Name of the MSSQL Security List"
  type        = string
  default     = "scslabsr_mssql_sl"
}
#variable service gateway name
variable "service_gw_name" {
  description = "Name of the Service Gateway"
  type        = string
  default     = "scslabsr_service_gw"
}