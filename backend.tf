terraform {
  backend "s3" {
    # Replace this with the S3 bucket created by backend-bootstrap.
    bucket = "rakesh-terraform-state-2026-unique"

    key    = "terraform.tfstate"
    region = "ap-south-1"

    # Native S3 locking. Terraform creates a .tflock object.
    use_lockfile = true

    encrypt = true
  }
}
