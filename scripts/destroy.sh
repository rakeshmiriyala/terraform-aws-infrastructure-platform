#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"

terraform workspace select "$ENVIRONMENT"
terraform destroy -var-file="env/${ENVIRONMENT}.tfvars"
