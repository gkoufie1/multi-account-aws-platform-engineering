module "organization" {
  source = "../../modules/organization"

  project_name                  = var.project_name
  enable_account_creation       = var.enable_account_creation
  security_account_email        = var.security_account_email
  shared_services_account_email = var.shared_services_account_email
  dev_account_email             = var.dev_account_email
  prod_account_email            = var.prod_account_email
}

module "logging" {
  source        = "../../modules/logging"
  project_name  = var.project_name
  environment   = var.environment
  force_destroy = var.force_destroy_buckets
}

module "iam_roles" {
  source       = "../../modules/iam-roles"
  project_name = var.project_name
}

module "security_guardrails" {
  source        = "../../modules/security-guardrails"
  project_name  = var.project_name
  force_destroy = var.force_destroy_buckets

  enable_securityhub_default_standards = var.enable_securityhub_default_standards
}

module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.20.0.0/16"
}

module "budget" {
  source               = "../../modules/budget"
  project_name         = var.project_name
  monthly_budget_limit = var.monthly_budget_limit
}

module "service_control_policies" {
  source       = "../../modules/service-control-policies"
  project_name = var.project_name

  all_ou_ids = {
    security        = module.organization.security_ou_id
    shared_services = module.organization.shared_services_ou_id
    workloads       = module.organization.workloads_ou_id
    sandbox         = module.organization.sandbox_ou_id
  }

  region_restricted_ou_ids = {
    workloads = module.organization.workloads_ou_id
    sandbox   = module.organization.sandbox_ou_id
  }

  allowed_regions = var.allowed_regions
}
