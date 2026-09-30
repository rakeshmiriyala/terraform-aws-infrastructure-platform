variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string

  validation {
    condition     = !contains(["REPLACE_ME_DEV_BUCKET", "REPLACE_ME_QA_BUCKET", "REPLACE_ME_PROD_BUCKET"], var.bucket_name)
    error_message = "Replace the placeholder bucket name with a globally unique S3 bucket name."
  }
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "tags" {
  description = "Tags for the bucket."
  type        = map(string)
  default     = {}
}
