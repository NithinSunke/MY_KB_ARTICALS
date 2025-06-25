# main.tf
terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  region              = var.region
  config_file_profile = var.config_file_profile
}

# VCN
resource "oci_core_vcn" "scslabsr_vcn" {
  cidr_block     = var.cidr_block
  display_name   = var.display_name
  compartment_id = var.compartment_id
  dns_label      = var.dns_label
}

# Internet Gateway
resource "oci_core_internet_gateway" "scslabsr_igw" {
  display_name   = var.igw_name
  vcn_id         = oci_core_vcn.scslabsr_vcn.id
  compartment_id = var.compartment_id
  enabled        = true
}

# NAT Gateway
resource "oci_core_nat_gateway" "scslabsr_nat_gw" {
  display_name   = var.nat_gw_name
  vcn_id         = oci_core_vcn.scslabsr_vcn.id
  compartment_id = var.compartment_id
}

# Service Gateway
resource "oci_core_service_gateway" "scslabsr_service_gw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.scslabsr_vcn.id
  display_name   = var.service_gw_name

  services {
    service_id = data.oci_core_services.services.services[0].id
  }
}

# Public Route Table
resource "oci_core_route_table" "scslabsr_public_rt" {
  display_name   = var.public_rt_name
  vcn_id         = oci_core_vcn.scslabsr_vcn.id
  compartment_id = var.compartment_id

  route_rules {
    destination       = "139.5.250.69/32"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.scslabsr_igw.id
  }
}

# Oracle Route Table
resource "oci_core_route_table" "scslabsr_oracle_rt" {
  display_name   = var.oracle_rt_name
  vcn_id         = oci_core_vcn.scslabsr_vcn.id
  compartment_id = var.compartment_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.scslabsr_nat_gw.id
  }

  route_rules {
    destination       = "all-ruh-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.scslabsr_service_gw.id
  }
}

# Oracle Route Table
resource "oci_core_route_table" "scslabsr_mssql_rt" {
  display_name   = var.mssql_rt_name
  vcn_id         = oci_core_vcn.scslabsr_vcn.id
  compartment_id = var.compartment_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.scslabsr_nat_gw.id
  }

  route_rules {
    destination       = "all-ruh-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.scslabsr_service_gw.id
  }
}

# Public Subnet
resource "oci_core_subnet" "scslabsr_public_subnet" {
  cidr_block                 = var.public_cidr_block
  display_name               = var.public_subnet_name
  vcn_id                     = oci_core_vcn.scslabsr_vcn.id
  compartment_id             = var.compartment_id
  route_table_id             = oci_core_route_table.scslabsr_public_rt.id
  security_list_ids          = [oci_core_security_list.scslabsr_public_sl.id]
  prohibit_public_ip_on_vnic = false
  dns_label                  = var.public_subnet_dns_label
}

# Oracle Subnet
resource "oci_core_subnet" "scslabsr_oracle_subnet" {
  cidr_block                 = var.oracle_cidr_block
  display_name               = var.oracle_subnet_name
  vcn_id                     = oci_core_vcn.scslabsr_vcn.id
  compartment_id             = var.compartment_id
  route_table_id             = oci_core_route_table.scslabsr_oracle_rt.id
  security_list_ids          = [oci_core_security_list.scslabsr_oracle_sl.id]
  dns_label                  = var.oracle_subnet_dns_label
  prohibit_public_ip_on_vnic = true
}

# MSSQL Subnet
resource "oci_core_subnet" "scslabsr_mssql_subnet" {
  cidr_block                 = var.mssql_cidr_block
  display_name               = var.mssql_subnet_name
  vcn_id                     = oci_core_vcn.scslabsr_vcn.id
  compartment_id             = var.compartment_id
  route_table_id             = oci_core_route_table.scslabsr_mssql_rt.id
  security_list_ids          = [oci_core_security_list.scslabsr_mssql_sl.id]
  dns_label                  = var.mssql_subnet_dns_label
  prohibit_public_ip_on_vnic = true
}

# Public Security List
resource "oci_core_security_list" "scslabsr_public_sl" {
  display_name   = var.public_sl_name
  vcn_id         = oci_core_vcn.scslabsr_vcn.id
  compartment_id = var.compartment_id

  ingress_security_rules {
    protocol    = "all"
    source      = var.my_ip
    source_type = "CIDR_BLOCK"
  }
  ingress_security_rules {
    protocol    = "all"
    source      = "11.0.0.0/16"
    source_type = "CIDR_BLOCK"
  }
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

# Oracle Security List
resource "oci_core_security_list" "scslabsr_oracle_sl" {
  display_name   = var.oracle_sl_name
  vcn_id         = oci_core_vcn.scslabsr_vcn.id
  compartment_id = var.compartment_id

  ingress_security_rules {
    protocol    = "all"
    source      = var.cidr_block
    source_type = "CIDR_BLOCK"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

# MSSQL Security List
resource "oci_core_security_list" "scslabsr_mssql_sl" {
  display_name   = var.mssql_sl_name
  vcn_id         = oci_core_vcn.scslabsr_vcn.id
  compartment_id = var.compartment_id

  ingress_security_rules {
    protocol    = "all"
    source      = var.cidr_block
    source_type = "CIDR_BLOCK"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}   

data "oci_core_services" "services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}


