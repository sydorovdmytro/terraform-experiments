output "private_subnet_ids" {
  description = "Map of private subnet ids keyed by AZ"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Map of public subnet ids keyed by AZ"
  value       = module.vpc.public_subnets
}

output "security_group_id" {
  description = "Security group id to attach to worker nodes"
  value       = aws_security_group.workers.id
}
