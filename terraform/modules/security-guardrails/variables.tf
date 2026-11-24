variable "project_name" {
  type = string
}


variable "force_destroy" {
  description = "Delete all objects (including old versions) when the bucket is destroyed."
  type        = bool
  default     = false
}

variable "enable_securityhub_default_standards" {
  description = "Subscribe Security Hub to the AWS Foundational Security Best Practices and CIS standards."
  type        = bool
  default     = false
}
