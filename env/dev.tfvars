aws_region   = "ap-south-1"
project_name = "terraform-cloud-platform"
admin_cidr   = "116.73.163.19/32"

enable_nat_gateway = true

extra_tags = {
  Owner      = "devops-team"
  CostCenter = "development"
}
