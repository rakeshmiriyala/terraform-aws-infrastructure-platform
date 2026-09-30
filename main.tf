module "vpc" {
  source = "./modules/vpc"

  name_prefix        = local.name_prefix
  vpc_cidr           = local.config.vpc_cidr
  availability_zones = local.config.availability_zones
  public_subnets     = local.config.public_subnets
  private_subnets    = local.config.private_subnets
  enable_nat_gateway = var.enable_nat_gateway
  nat_gateway_count  = local.config.nat_gateway_count
  tags               = local.common_tags
}

module "ec2" {
  source = "./modules/ec2"

  name_prefix         = local.name_prefix
  ami_id              = data.aws_ami.amazon_linux.id
  instance_type       = local.config.instance_type
  instance_count      = local.config.ec2_count
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  associate_public_ip = local.config.associate_public_ip
  admin_cidr          = var.admin_cidr
  tags                = local.common_tags

  depends_on = [module.vpc]
}

module "s3" {
  source = "./modules/s3"

  bucket_name = local.config.s3_bucket_name
  environment = local.environment
  tags        = local.common_tags
}
