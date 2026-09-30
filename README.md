# 🚀 Production-Style AWS Infrastructure with Terraform

> **Reusable, modular and environment-aware AWS infrastructure provisioned using Terraform**

A production-style Infrastructure as Code (IaC) project demonstrating how a DevOps / Cloud Engineer can design, provision, and manage AWS infrastructure using **Terraform modules, remote state, workspaces, environment-specific configuration, networking, security, data sources, variables, locals, and outputs**.

The project provisions an isolated AWS environment containing a **VPC, public/private subnets, routing, NAT gateways, security groups, EC2 instances, and encrypted S3 buckets**.

---

## 🏗️ Architecture

```text
                                  AWS
                                   │
                            Terraform CLI
                                   │
                  ┌────────────────┴────────────────┐
                  │                                 │
          Terraform Backend                  Infrastructure
                  │                                 │
             S3 State Bucket                       │
                  │                                 │
        ┌─────────┼─────────┐                       │
        │         │         │                       │
       DEV       QA       PROD                      │
     State      State      State                    │
        │         │         │                       │
        └─────────┴─────────┘                       │
                  │                                 │
           Native S3 Locking                        │
              *.tflock                             │
                                                    │
                                          terraform.workspace
                                                    │
                              ┌─────────────────────┼─────────────────────┐
                              │                     │                     │
                             DEV                   QA                    PROD
                              │                     │                     │
                              └─────────────────────┼─────────────────────┘
                                                    │
                                                VPC Module
                                                    │
                         ┌──────────────────────────┼──────────────────────────┐
                         │                          │                          │
                        VPC                     Subnets                    Routing
                         │                          │                          │
                         │                 ┌────────┴────────┐                 │
                         │                 │                 │                 │
                         │               Public            Private             │
                         │              Subnets           Subnets              │
                         │                 │                 │                 │
                         │                 │              NAT Gateway          │
                         │                 │                 │                 │
                         └─────────────────┴─────────────────┴─────────────────┘
                                                    │
                                             Module Outputs
                                                    │
                                                EC2 Module
                                                    │
                                         ┌──────────┴──────────┐
                                         │                     │
                                  Security Group             EC2
                                         │                     │
                                   SSH/HTTP/HTTPS        Amazon Linux
                                         │                     │
                                         └──────────┬──────────┘
                                                    │
                                                S3 Module
                                                    │
                              ┌─────────────────────┼─────────────────────┐
                              │                     │                     │
                         app-dev-bucket        app-qa-bucket        app-prod-bucket
```

---

## ✨ Key Features

### Infrastructure as Code

* Fully automated AWS infrastructure provisioning
* Declarative Terraform configuration
* Reproducible infrastructure
* Version-controlled infrastructure

### Terraform Modules

Reusable modules for:

* 🌐 VPC
* 🖥️ EC2
* 🪣 S3

### Environment Management

Separate Terraform workspaces:

```text
dev
qa
prod
```

Each environment has different infrastructure sizing and networking configuration.

### Remote State

Terraform state is stored remotely in:

```text
AWS S3
```

with:

* Versioning
* Server-side encryption
* Native Terraform S3 state locking
* `.tflock` lock files

### Networking

The VPC module provisions:

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateways
* Public route table
* Private route tables
* Route table associations

### Security

The project includes:

* Security groups
* Restricted SSH access
* HTTP/HTTPS access
* S3 public-access blocking
* S3 encryption
* EC2 encrypted root volumes
* IMDSv2 enforcement

### AWS Data Sources

Terraform dynamically discovers:

* AWS account ID
* AWS region
* Latest Amazon Linux 2023 AMI

---

# 📁 Project Structure

```text
terraform-aws-production/
│
├── backend-bootstrap/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
│
├── modules/
│   │
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── s3/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── env/
│   ├── dev.tfvars
│   ├── qa.tfvars
│   └── prod.tfvars
│
├── docs/
│   └── WORKSPACES.md
│
├── scripts/
│   ├── init.sh
│   ├── plan.sh
│   ├── apply.sh
│   └── destroy.sh
│
├── backend.tf
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── versions.tf
├── terraform.tfvars.example
├── .gitignore
└── README.md
```

---

# ☁️ Infrastructure by Environment

| Configuration      |            DEV |             QA |           PROD |
| ------------------ | -------------: | -------------: | -------------: |
| VPC CIDR           | `10.10.0.0/16` | `10.20.0.0/16` | `10.30.0.0/16` |
| Availability Zones |              2 |              2 |              3 |
| Public Subnets     |              2 |              2 |              3 |
| Private Subnets    |              2 |              2 |              3 |
| EC2 Instances      |              1 |              2 |              3 |
| EC2 Type           |     `t3.micro` |     `t3.small` |    `t3.medium` |
| NAT Gateways       |              1 |              1 |              3 |
| S3 Bucket          |      Dedicated |      Dedicated |      Dedicated |
| Terraform State    |       Isolated |       Isolated |       Isolated |

---

# 🔄 Terraform Workflow

```text
Developer
    │
    ▼
Terraform Configuration
    │
    ▼
terraform init
    │
    ▼
Remote S3 Backend
    │
    ▼
terraform workspace select
    │
    ├──────────────┬──────────────┐
    ▼              ▼              ▼
   DEV            QA             PROD
    │              │              │
    └──────────────┼──────────────┘
                   ▼
              terraform plan
                   │
                   ▼
              Review Changes
                   │
                   ▼
             terraform apply
                   │
                   ▼
             AWS Infrastructure
```

---

# 🧩 Terraform Concepts Demonstrated

## Variables

Environment-independent configuration is defined using Terraform variables.

Example:

```hcl
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
```

---

## Locals

Environment configuration and common tags are centralized using locals.

```hcl
locals {
  environment = terraform.workspace

  name_prefix = "${var.project_name}-${local.environment}"
}
```

---

## Data Sources

AWS resources are dynamically discovered instead of hard-coding values.

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
}
```

---

## Modules

The root configuration consumes reusable modules:

```hcl
module "vpc" {
  source = "./modules/vpc"
}
```

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

```hcl
module "s3" {
  source = "./modules/s3"
}
```

---

## Outputs

Important infrastructure information is exposed through outputs.

```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}
```

Examples:

```text
VPC ID
Subnet IDs
EC2 instance IDs
Private IP addresses
Security Group ID
S3 bucket name
S3 bucket ARN
```

---

# 🌎 Terraform Workspaces

The project uses:

```text
dev
qa
prod
```

Terraform determines the active environment using:

```hcl
terraform.workspace
```

Example:

```hcl
locals {
  environment = terraform.workspace
}
```

This allows the same Terraform code to create different infrastructure configurations.

### DEV

```text
1 × t3.micro
2 × AZ
1 × NAT Gateway
```

### QA

```text
2 × t3.small
2 × AZ
1 × NAT Gateway
```

### PROD

```text
3 × t3.medium
3 × AZ
3 × NAT Gateway
```

> **Note:** Terraform workspaces provide state separation, but they are not a substitute for AWS account-level isolation. Larger production environments should generally consider separate AWS accounts for DEV, QA and PROD.

---

# 🔐 Security Architecture

The project implements several AWS security best practices.

### EC2 Security Group

Inbound traffic:

```text
SSH     → Trusted administrator CIDR
HTTP    → 0.0.0.0/0
HTTPS   → 0.0.0.0/0
```

Outbound:

```text
All outbound traffic
```

SSH should be restricted to a trusted VPN, corporate network, bastion host, or administrator IP.

---

### S3 Security

Application buckets have:

```text
✔ Public access blocked
✔ Versioning enabled
✔ Server-side encryption
✔ Bucket ownership enforced
✔ Lifecycle management
```

---

### EC2 Security

Instances use:

```text
✔ Encrypted EBS volumes
✔ GP3 storage
✔ IMDSv2
✔ Private subnets where configured
✔ Security groups
```

---

# 🗄️ Terraform Remote State

The project separates backend creation from infrastructure provisioning.

```text
backend-bootstrap/
        │
        ▼
Terraform State S3 Bucket
        │
        ▼
main Terraform project
        │
        ├── DEV state
        ├── QA state
        └── PROD state
```

The backend uses:

```hcl
terraform {
  backend "s3" {
    bucket       = "..."
    key          = "terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
```

Terraform's native S3 lock-file mechanism creates:

```text
terraform.tfstate.tflock
```

during state operations.

---

# 🚀 Getting Started

## Prerequisites

Install:

* Terraform
* AWS CLI
* AWS account
* Appropriate AWS IAM permissions

Verify:

```bash
terraform version
aws --version
aws sts get-caller-identity
```

---

# 1️⃣ Create the Terraform Backend

Navigate to:

```bash
cd backend-bootstrap
```

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Create the state bucket:

```bash
terraform apply \
  -var="bucket_name=YOUR-UNIQUE-TERRAFORM-STATE-BUCKET"
```

Example:

```bash
terraform apply \
  -var="bucket_name=my-company-terraform-state-2026"
```

---

# 2️⃣ Configure the Main Backend

Return to the project root:

```bash
cd ..
```

Update:

```text
backend.tf
```

with your state bucket:

```hcl
terraform {
  backend "s3" {
    bucket       = "YOUR-TERRAFORM-STATE-BUCKET"
    key          = "terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
```

Initialize:

```bash
terraform init
```

---

# 3️⃣ Configure Environment Variables

Update:

```text
env/dev.tfvars
env/qa.tfvars
env/prod.tfvars
```

Set your trusted administrator CIDR:

```hcl
admin_cidr = "YOUR_PUBLIC_IP/32"
```

Example:

```hcl
admin_cidr = "49.204.xxx.xxx/32"
```

Also configure unique S3 bucket names in:

```text
locals.tf
```

---

# 4️⃣ Validate the Configuration

Format:

```bash
terraform fmt -recursive
```

Validate:

```bash
terraform validate
```

---

# 5️⃣ Create Terraform Workspaces

```bash
terraform workspace new dev
terraform workspace new qa
terraform workspace new prod
```

List:

```bash
terraform workspace list
```

---

# 6️⃣ Deploy DEV

```bash
terraform workspace select dev

terraform plan \
  -var-file="env/dev.tfvars"

terraform apply \
  -var-file="env/dev.tfvars"
```

---

# 7️⃣ Deploy QA

```bash
terraform workspace select qa

terraform plan \
  -var-file="env/qa.tfvars"

terraform apply \
  -var-file="env/qa.tfvars"
```

---

# 8️⃣ Deploy PROD

```bash
terraform workspace select prod

terraform plan \
  -var-file="env/prod.tfvars"

terraform apply \
  -var-file="env/prod.tfvars"
```

---

# 🔍 Useful Commands

### Current workspace

```bash
terraform workspace show
```

### List workspaces

```bash
terraform workspace list
```

### Terraform plan

```bash
terraform plan -var-file="env/dev.tfvars"
```

### Terraform outputs

```bash
terraform output
```

### State resources

```bash
terraform state list
```

### Inspect resource

```bash
terraform state show module.vpc.aws_vpc.this
```

### Format

```bash
terraform fmt -recursive
```

### Validate

```bash
terraform validate
```

### Destroy an environment

```bash
terraform workspace select dev
terraform destroy -var-file="env/dev.tfvars"
```

---

# 📊 Terraform Resource Flow

```text
terraform.workspace
        │
        ▼
Environment Configuration
        │
        ▼
     VPC Module
        │
        ├── VPC
        ├── Public Subnets
        ├── Private Subnets
        ├── Internet Gateway
        ├── NAT Gateway
        └── Route Tables
                │
                ▼
          Module Outputs
                │
                ▼
            EC2 Module
                │
                ├── Security Group
                └── EC2 Instances
                        
                │
                ▼
             S3 Module
                │
                ├── Bucket
                ├── Encryption
                ├── Versioning
                └── Public Access Block
```

---

# 🧠 DevOps / Cloud Engineering Concepts

This project demonstrates practical knowledge of:

```text
Terraform
│
├── Providers
├── Resources
├── Variables
├── Locals
├── Outputs
├── Data Sources
├── Modules
├── Workspaces
├── Remote State
├── State Locking
├── Environment Configuration
├── Resource Dependencies
├── Input Validation
└── Infrastructure Lifecycle
```

AWS:

```text
AWS
│
├── VPC
├── Subnets
├── Route Tables
├── Internet Gateway
├── NAT Gateway
├── Elastic IP
├── Security Groups
├── EC2
├── S3
└── IAM-aware authentication
```

---

# 🔮 Production Evolution

This project can be extended into a larger enterprise platform with:

```text
GitHub
   │
   ▼
Pull Request
   │
   ▼
Terraform fmt / validate
   │
   ▼
Security Scanning
   │
   ├── Checkov
   ├── tfsec
   └── Trivy
   │
   ▼
Terraform Plan
   │
   ▼
Approval
   │
   ▼
Terraform Apply
   │
   ├── DEV
   ├── QA
   └── PROD
```

Potential improvements include:

* AWS Organizations
* Separate AWS accounts for environments
* IAM roles with OIDC
* GitHub Actions / Azure DevOps CI/CD
* Terraform Cloud / HCP Terraform
* Policy-as-code
* Checkov / Trivy security scanning
* AWS CloudTrail
* AWS Config
* VPC endpoints
* AWS Systems Manager Session Manager
* Application Load Balancer
* Auto Scaling Groups
* CloudWatch monitoring
* Centralized logging
* Secrets Manager
* Parameter Store

---

# 🎯 Project Objective

The goal of this project is to demonstrate how Terraform can be used to build **reusable, secure and environment-aware AWS infrastructure** rather than managing individual AWS resources manually.

It provides a foundation for implementing Terraform within a modern DevOps / Cloud Engineering workflow.

---

## 👨‍💻 Author

**Rakesh Miriyala**

Cloud & DevOps Engineer

### Core Technologies

```text
AWS
Terraform
Docker
Kubernetes
Azure
CI/CD
GitOps
Linux
Infrastructure as Code
Cloud Automation
```

---

## 📜 License

This project is intended for educational, portfolio and demonstration purposes.
