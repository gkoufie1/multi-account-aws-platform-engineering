provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  # Refuse to run against any account other than the one(s) listed.
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "PlatformEngineering"
    }
  }
}
