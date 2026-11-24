variable "project_name" {
  type = string
}

variable "all_ou_ids" {
  description = "OUs that receive the baseline guardrails (deny leaving the org, protect security services, deny root user)."
  type        = map(string)
}

variable "region_restricted_ou_ids" {
  description = "OUs that are limited to allowed_regions."
  type        = map(string)
}

variable "allowed_regions" {
  description = "Regions member accounts in region-restricted OUs may use."
  type        = list(string)
}

variable "break_glass_role_name" {
  description = "IAM role exempt from the guardrails, used for administration from the management account."
  type        = string
  default     = "OrganizationAccountAccessRole"
}
