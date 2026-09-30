output "state_bucket_name" {
  description = "Terraform state bucket name."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "Terraform state bucket ARN."
  value       = aws_s3_bucket.terraform_state.arn
}

output "backend_region" {
  description = "Region containing the state bucket."
  value       = var.aws_region
}
