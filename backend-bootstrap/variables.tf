variable "aws_region" {
  description = "AWS region for the backend bucket."
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string

  validation {
    condition     = length(var.bucket_name) >= 3 && can(regex("^[a-z0-9][a-z0-9.-]+[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be a valid S3 bucket name."
  }
}
