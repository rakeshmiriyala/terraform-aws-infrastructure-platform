# Production-Style AWS Terraform Infrastructure

A reusable Terraform project demonstrating common DevOps / Cloud Engineer patterns:

- AWS provider
- Remote Terraform state in S3
- Native S3 state locking with `.tflock`
- Terraform workspaces: `dev`, `qa`, `prod`
- Workspace-specific configuration
- Reusable Terraform modules
- VPC, public/private subnets, route tables and Internet/NAT gateways
- Security groups
- EC2 provisioning
- S3 application buckets
- Variables, locals, outputs and data sources
- Input validation and preconditions
- Environment-aware naming and tagging
- Separate bootstrap configuration for the remote state bucket
- No hard-coded AWS credentials

## Architecture

```text
                              AWS ACCOUNT
                                  |
                             Terraform CLI
                                  |
                +-----------------+------------------+
                |                                    |
        Terraform Backend                      Infrastructure
                |                                    |
        +-------+--------+                           |
        |                |                           |
   S3 State Bucket   S3 Lock Files                  |
        |                |                           |
  envs/dev/...       *.tflock                        |
  envs/qa/...                                         |
  envs/prod/...                                       |
                |                                    |
                +------------- workspace ------------+
                              /   |   \
                            dev   qa   prod
                              \   |   /
                               VPC MODULE
                                  |
              +-------------------+-------------------+
              |                   |                   |
             VPC              Subnets              Routes
              |                   |                   |
              +-------------------+-------------------+
                                  |
                             module outputs
                                  |
                             EC2 MODULE
                          +-------+--------+
                          |                |
                    Security Group        EC2
                          |
                   Inbound / Outbound
                                  |
                             S3 MODULE
                                  |
                  +---------------+---------------+
                  |               |               |
              app-dev         app-qa          app-prod
```

## Repository structure

```text
terraform-aws-production/
├── backend-bootstrap/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── s3/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── env/
│   ├── dev.tfvars
│   ├── qa.tfvars
│   └── prod.tfvars
├── main.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── data.tf
├── outputs.tf
├── versions.tf
├── backend.tf
├── terraform.tfvars.example
├── .gitignore
└── scripts/
    ├── init.sh
    ├── plan.sh
    ├── apply.sh
    └── destroy.sh
```

## Prerequisites

- Terraform >= 1.10
- AWS CLI
- An AWS account
- IAM permissions to create the resources in this project
- AWS credentials configured outside Terraform

Recommended:

```bash
aws configure
aws sts get-caller-identity
terraform version
```

Never put an AWS access key or secret in `.tf` files.

---

# 1. Bootstrap the Terraform backend

Terraform cannot use an S3 backend until the backend bucket already exists.

Go into:

```bash
cd backend-bootstrap
```

Create a unique bucket name, because S3 bucket names are globally unique.

Example:

```bash
terraform init
terraform apply -var="bucket_name=my-company-terraform-state-123456"
```

The bootstrap module creates:

- S3 bucket
- Versioning
- Default encryption
- Public access block
- Lifecycle configuration
- Native S3 lock-file support is used by the main Terraform configuration

Save the output bucket name.

---

# 2. Configure the backend

Edit `backend.tf` and replace:

```hcl
bucket = "REPLACE_WITH_YOUR_UNIQUE_STATE_BUCKET"
```

Example:

```hcl
bucket = "my-company-terraform-state-123456"
```

The backend uses:

```text
envs/dev/terraform.tfstate
envs/qa/terraform.tfstate
envs/prod/terraform.tfstate
```

The lock file is stored beside the state as:

```text
terraform.tfstate.tflock
```

Do not create the lock files manually.

---

# 3. Initialize the main project

From the repository root:

```bash
terraform init
```

Verify:

```bash
terraform workspace list
```

---

# 4. Create workspaces

```bash
terraform workspace new dev
terraform workspace new qa
terraform workspace new prod
```

If they already exist:

```bash
terraform workspace select dev
```

Check:

```bash
terraform workspace show
```

---

# 5. Deploy DEV

```bash
terraform workspace select dev
terraform plan -var-file="env/dev.tfvars"
terraform apply -var-file="env/dev.tfvars"
```

---

# 6. Deploy QA

```bash
terraform workspace select qa
terraform plan -var-file="env/qa.tfvars"
terraform apply -var-file="env/qa.tfvars"
```

---

# 7. Deploy PROD

```bash
terraform workspace select prod
terraform plan -var-file="env/prod.tfvars"
terraform apply -var-file="env/prod.tfvars"
```

Production is deliberately configured with multiple AZs, private application subnets, NAT gateways and stronger EC2 defaults.

---

# Workspace-specific behavior

The workspace is read using:

```hcl
terraform.workspace
```

The root module converts it into environment configuration.

Example:

```hcl
locals {
  environment = terraform.workspace
}
```

Then the environment configuration controls:

- CIDR blocks
- Availability Zones
- Instance type
- Desired number of EC2 instances
- S3 bucket name
- NAT gateway count
- Public IP behavior
- tags

This means the same Terraform code can provision different environments.

---

# Important security note

The default EC2 security group intentionally allows HTTP/HTTPS and SSH only from the configured `admin_cidr`.

For production, do not use:

```text
0.0.0.0/0
```

for SSH.

Set `admin_cidr` to your corporate VPN, bastion host, or trusted administrator CIDR.

---

# Useful commands

Format:

```bash
terraform fmt -recursive
```

Validate:

```bash
terraform validate
```

Inspect plan:

```bash
terraform plan -var-file="env/dev.tfvars"
```

Show outputs:

```bash
terraform output
```

Show current workspace:

```bash
terraform workspace show
```

List workspaces:

```bash
terraform workspace list
```

Destroy only the current workspace:

```bash
terraform destroy -var-file="env/dev.tfvars"
```

---

# Interview concepts demonstrated

## Variables

Root input variables are defined in `variables.tf`.

Modules have their own input variables.

## Outputs

The VPC exposes:

- VPC ID
- public subnet IDs
- private subnet IDs
- route table IDs

The EC2 module exposes:

- instance IDs
- private IPs
- security group ID

The S3 module exposes:

- bucket name
- bucket ARN

## Locals

`locals.tf` creates:

- environment name
- common tags
- naming prefix
- workspace-specific defaults

## Data sources

`data.tf` looks up:

- current AWS account
- current AWS region
- latest Amazon Linux 2023 AMI

## Modules

```text
module.vpc
module.ec2
module.s3
```

## Workspaces

```text
dev
qa
prod
```

## Remote state

S3 stores state centrally.

Native S3 locking uses:

```text
*.tflock
```

## Environment isolation

Each workspace has a separate state object.

---

# Production evolution

For a larger organization, consider:

1. Separate AWS accounts for dev/qa/prod.
2. AWS Organizations / Control Tower.
3. IAM roles and OIDC instead of long-lived credentials.
4. CI/CD with GitHub Actions or AWS CodePipeline.
5. Terraform plan on pull request.
6. Manual approval before production apply.
7. Policy-as-code using OPA/Conftest or Sentinel.
8. Checkov/tfsec scanning.
9. CloudTrail and centralized logging.
10. AWS Config.
11. VPC endpoints.
12. Private EC2 without public IPs.
13. SSM Session Manager instead of SSH.
14. Autoscaling groups instead of individual EC2 instances.
15. ALB + Auto Scaling for production applications.
16. Separate state buckets/accounts for stronger blast-radius isolation.

This repository is intentionally designed as a learning + portfolio project while keeping the structure close to patterns used in real infrastructure repositories.
