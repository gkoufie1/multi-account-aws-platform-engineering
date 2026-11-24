# Placeholder module for account vending/baseline expansion.
# In production, use this module with provider aliases to assume into each child account
# and deploy IAM roles, CloudTrail/Config/GuardDuty delegation, VPC baselines, tags, and budgets.
locals {
  baseline_name = "${var.account_name}-${var.environment}-baseline"
}
