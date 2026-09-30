# Backend Bootstrap

This small Terraform stack creates the S3 bucket used by the main Terraform project.

Terraform backend resources must exist before Terraform can initialize the main remote backend.

## Create

```bash
terraform init
terraform apply -var="bucket_name=my-company-terraform-state-123456"
```

Then copy the output bucket name into the root `backend.tf`.

## Why separate bootstrap code?

A backend cannot normally manage the bucket that it itself needs to initialize against. Separating the bootstrap step avoids that dependency cycle.

## Locking

The main configuration uses Terraform's native S3 lock file:

```hcl
use_lockfile = true
```

Terraform creates a `.tflock` object during state operations.
