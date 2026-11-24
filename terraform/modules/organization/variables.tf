variable "project_name" {
  type = string
}

variable "enable_account_creation" {
  type    = bool
  default = false
}

variable "security_account_email" {
  type = string
}

variable "shared_services_account_email" {
  type = string
}

variable "dev_account_email" {
  type = string
}

variable "prod_account_email" {
  type = string
}

