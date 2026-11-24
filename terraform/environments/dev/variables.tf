variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "multi-account-platform"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "enable_account_creation" {
  type    = bool
  default = false
}

variable "security_account_email" {
  type    = string
  default = "security-account@example.com"
}

variable "shared_services_account_email" {
  type    = string
  default = "shared-services-account@example.com"
}

variable "dev_account_email" {
  type    = string
  default = "dev-account@example.com"
}

variable "prod_account_email" {
  type    = string
  default = "prod-account@example.com"
}

variable "monthly_budget_limit" {
  type    = string
  default = "25"
}

variable "allowed_regions" {
  description = "Regions member accounts in the Workloads and Sandbox OUs may use."
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "aws_profile" {
  description = "AWS CLI profile to use. null means the default credential chain."
  type        = string
  default     = null
}

variable "allowed_account_ids" {
  description = "Account IDs Terraform is allowed to run against. Set in terraform.tfvars (git-ignored)."
  type        = list(string)

  validation {
    condition     = length(var.allowed_account_ids) > 0
    error_message = "Set allowed_account_ids so Terraform cannot run against the wrong account."
  }
}

variable "force_destroy_buckets" {
  description = "Let terraform destroy empty and delete the log and Config buckets. Fine for a lab; set false where logs must be retained."
  type        = bool
  default     = true
}

variable "enable_securityhub_default_standards" {
  description = "Turn on Security Hub's default standards. Adds AWS Config rule evaluation charges."
  type        = bool
  default     = false
}
