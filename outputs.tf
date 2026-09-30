output "aws_account_id" {
  description = "AWS account ID returned by the caller identity data source."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region."
  value       = data.aws_region.current.region
}

output "workspace" {
  description = "Current Terraform workspace."
  value       = terraform.workspace
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "ec2_instance_ids" {
  description = "EC2 instance IDs."
  value       = module.ec2.instance_ids
}

output "ec2_private_ips" {
  description = "Private IPs of EC2 instances."
  value       = module.ec2.private_ips
}

output "ec2_security_group_id" {
  description = "Security group attached to the EC2 instances."
  value       = module.ec2.security_group_id
}

output "application_bucket_name" {
  description = "Application S3 bucket."
  value       = module.s3.bucket_name
}

output "application_bucket_arn" {
  description = "Application S3 bucket ARN."
  value       = module.s3.bucket_arn
}
