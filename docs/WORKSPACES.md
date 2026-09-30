# Terraform Workspaces and Environment Configuration

This project intentionally uses Terraform workspaces for demonstration and interview purposes.

## Workspace selection

```bash
terraform workspace select dev
terraform workspace select qa
terraform workspace select prod
```

The code reads:

```hcl
terraform.workspace
```

and maps it to a configuration object.

## Example

```hcl
locals {
  environment = terraform.workspace

  environment_config = {
    dev = {
      instance_type = "t3.micro"
    }

    qa = {
      instance_type = "t3.small"
    }

    prod = {
      instance_type = "t3.medium"
    }
  }
}
```

The same module is therefore reused with different inputs.

## Important distinction

Terraform workspaces separate Terraform state, but they do not provide strong security/account isolation.

For serious production organizations, a common evolution is:

```text
AWS Account: DEV
AWS Account: QA
AWS Account: PROD
```

with separate state backends and IAM roles.

Workspaces are still useful for learning, smaller projects and certain controlled use cases.
