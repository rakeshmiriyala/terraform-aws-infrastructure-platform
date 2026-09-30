locals {
  environment = terraform.workspace

  environment_config = {
    dev = {
      vpc_cidr            = "10.10.0.0/16"
      availability_zones  = ["ap-south-1a", "ap-south-1b"]
      public_subnets      = ["10.10.1.0/24", "10.10.2.0/24"]
      private_subnets     = ["10.10.11.0/24", "10.10.12.0/24"]
      instance_type       = "t3.micro"
      ec2_count           = 1
      nat_gateway_count   = 1
      s3_bucket_name      = "rakesh-terraform-app-dev-2026"
      associate_public_ip = true
    }

    qa = {
      vpc_cidr            = "10.20.0.0/16"
      availability_zones  = ["ap-south-1a", "ap-south-1b"]
      public_subnets      = ["10.20.1.0/24", "10.20.2.0/24"]
      private_subnets     = ["10.20.11.0/24", "10.20.12.0/24"]
      instance_type       = "t3.small"
      ec2_count           = 2
      nat_gateway_count   = 1
      s3_bucket_name      = "rakesh-terraform-app-qa-2026"
      associate_public_ip = false
    }

    prod = {
      vpc_cidr            = "10.30.0.0/16"
      availability_zones  = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
      public_subnets      = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
      private_subnets     = ["10.30.11.0/24", "10.30.12.0/24", "10.30.13.0/24"]
      instance_type       = "t3.medium"
      ec2_count           = 3
      nat_gateway_count   = 3
      s3_bucket_name      = "rakesh-terraform-app-prod-2026"
      associate_public_ip = false
    }
  }

  config = local.environment_config[local.environment]

  name_prefix = "${var.project_name}-${local.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = local.environment
      ManagedBy   = "Terraform"
      Workspace   = local.environment
    },
    var.extra_tags
  )
}
