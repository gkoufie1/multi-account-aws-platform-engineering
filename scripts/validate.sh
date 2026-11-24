#!/usr/bin/env bash
set -euo pipefail
terraform fmt -recursive -check
cd terraform/environments/dev
terraform init -backend=false
terraform validate
