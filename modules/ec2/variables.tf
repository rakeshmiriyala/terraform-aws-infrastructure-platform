variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "ami_id" {
  description = "AMI ID."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances."
  type        = number

  validation {
    condition     = var.instance_count >= 1
    error_message = "instance_count must be at least 1."
  }
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "At least one subnet is required."
  }
}

variable "associate_public_ip" {
  description = "Associate a public IP with instances."
  type        = bool
  default     = false
}

variable "admin_cidr" {
  description = "Trusted CIDR allowed to access SSH."
  type        = string
}

variable "tags" {
  description = "Tags for resources."
  type        = map(string)
  default     = {}
}
