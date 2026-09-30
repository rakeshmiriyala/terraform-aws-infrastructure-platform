#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"

terraform workspace select "$ENVIRONMENT"
terraform validate
terraform plan -var-file="env/${ENVIRONMENT}.tfvars"
terraform apply -var-file="env/${ENVIRONMENT}.tfvars"
