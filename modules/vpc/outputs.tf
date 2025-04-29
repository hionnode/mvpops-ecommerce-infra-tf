# modules/vpc/outputs.tf
output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}
output "private_subnet_ids" {
  description = "List of IDs of the private subnets."
  value       = aws_subnet.private[*].id
}
output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = aws_subnet.public[*].id
}
output "nat_gateway_public_ips" {
  description = "List of public EIPs associated with the NAT gateways (if any)."
  value       = aws_eip.nat[*].public_ip
}