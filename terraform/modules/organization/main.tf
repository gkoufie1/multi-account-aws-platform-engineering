data "aws_organizations_organization" "current" {}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_organizational_unit" "shared_services" {
  name      = "Shared-Services"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_account" "security" {
  count     = var.enable_account_creation ? 1 : 0
  name      = "Security-Account"
  email     = var.security_account_email
  parent_id = aws_organizations_organizational_unit.security.id
}

resource "aws_organizations_account" "shared_services" {
  count     = var.enable_account_creation ? 1 : 0
  name      = "Shared-Services-Account"
  email     = var.shared_services_account_email
  parent_id = aws_organizations_organizational_unit.shared_services.id
}

resource "aws_organizations_account" "dev" {
  count     = var.enable_account_creation ? 1 : 0
  name      = "Development-Account"
  email     = var.dev_account_email
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_account" "prod" {
  count     = var.enable_account_creation ? 1 : 0
  name      = "Production-Account"
  email     = var.prod_account_email
  parent_id = aws_organizations_organizational_unit.workloads.id
}
