aws_region   = "ap-south-1"
project_name = "terraform-cloud-platform"
admin_cidr   = "YOUR_PUBLIC_OR_VPN_CIDR/32"

enable_nat_gateway = true

extra_tags = {
  Owner      = "devops-team"
  CostCenter = "qa"
}
