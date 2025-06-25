# outputs.tf
output "vcn_id" {
  value = oci_core_vcn.scslabsr_vcn.id
}

output "public_subnet_id" {
  value = oci_core_subnet.scslabsr_public_subnet.id
}

output "oracle_subnet_id" {
  value = oci_core_subnet.scslabsr_oracle_subnet.id
}

output "mssql_subnet_id" {
  value = oci_core_subnet.scslabsr_mssql_subnet.id
}

output "internet_gateway_id" {
  value = oci_core_internet_gateway.scslabsr_igw.id
}

output "nat_gateway_id" {
  value = oci_core_nat_gateway.scslabsr_nat_gw.id
}

output "service_gateway_id" {
  value = oci_core_service_gateway.scslabsr_service_gw.id
}