variable "aws_region" {
  description = "AWS region where infrastructure is deployed."
  type        = string
  default     = "ap-south-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS region format."
  }
}

variable "project_name" {
  description = "Project/application name used for resource naming."
  type        = string
  default     = "terraform-cloud-platform"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name may contain only lowercase letters, numbers and hyphens."
  }
}

variable "admin_cidr" {
  description = "CIDR allowed to access EC2 over SSH. Restrict this to a trusted network."
  type        = string
  sensitive   = false

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid IPv4 CIDR block."
  }
}

variable "enable_nat_gateway" {
  description = "Whether private subnets should have outbound internet through NAT."
  type        = bool
  default     = true
}

variable "extra_tags" {
  description = "Additional tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
