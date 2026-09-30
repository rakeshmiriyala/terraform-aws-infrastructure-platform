variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR."
  }
}

variable "availability_zones" {
  description = "Availability Zones."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones are required."
  }
}

variable "public_subnets" {
  description = "Public subnet CIDRs, one per Availability Zone."
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDRs, one per Availability Zone."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create NAT gateways for private subnet egress."
  type        = bool
  default     = true
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways. Zero is valid when NAT is disabled."
  type        = number
  default     = 1

  validation {
    condition     = var.nat_gateway_count >= 0
    error_message = "nat_gateway_count must be zero or greater."
  }
}

variable "tags" {
  description = "Tags for resources."
  type        = map(string)
  default     = {}
}
