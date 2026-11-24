# Preventive guardrails enforced by AWS Organizations.
# SCPs never apply to the management account, only to member accounts in the targeted OUs.
# Prerequisite: the SERVICE_CONTROL_POLICY policy type must be enabled on the organization root.

data "aws_organizations_organization" "current" {}

locals {
  scp_enabled = anytrue([
    for p in data.aws_organizations_organization.current.roots[0].policy_types :
    p.type == "SERVICE_CONTROL_POLICY" && p.status == "ENABLED"
  ])

  break_glass_arn = "arn:aws:iam::*:role/${var.break_glass_role_name}"
}

data "aws_iam_policy_document" "baseline" {
  statement {
    sid       = "DenyLeaveOrganization"
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization"]
    resources = ["*"]
  }

  statement {
    sid    = "ProtectSecurityServices"
    effect = "Deny"
    actions = [
      "cloudtrail:DeleteTrail",
      "cloudtrail:StopLogging",
      "cloudtrail:UpdateTrail",
      "cloudtrail:PutEventSelectors",
      "guardduty:DeleteDetector",
      "guardduty:DisassociateFromMasterAccount",
      "guardduty:DisassociateFromAdministratorAccount",
      "guardduty:UpdateDetector",
      "config:DeleteConfigurationRecorder",
      "config:DeleteDeliveryChannel",
      "config:StopConfigurationRecorder",
      "securityhub:DisableSecurityHub",
      "securityhub:DisassociateFromMasterAccount",
      "securityhub:DisassociateFromAdministratorAccount",
    ]
    resources = ["*"]
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = [local.break_glass_arn]
    }
  }

  statement {
    sid       = "DenyRootUser"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

data "aws_iam_policy_document" "region_restriction" {
  statement {
    sid    = "DenyOutsideAllowedRegions"
    effect = "Deny"
    # Global services are exempt because their endpoints live in us-east-1.
    not_actions = [
      "a4b:*", "access-analyzer:*", "account:*", "acm:*", "aws-portal:*", "budgets:*",
      "ce:*", "chime:*", "cloudfront:*", "config:*", "cur:*", "directconnect:*",
      "ec2:DescribeRegions", "ec2:DescribeTransitGateways", "ec2:DescribeVpnGateways",
      "fms:*", "globalaccelerator:*", "health:*", "iam:*", "importexport:*", "kms:*",
      "mobileanalytics:*", "networkmanager:*", "organizations:*", "pricing:*",
      "route53:*", "route53domains:*", "route53-recovery-cluster:*",
      "route53-recovery-control-config:*", "route53-recovery-readiness:*",
      "s3:GetAccountPublic*", "s3:ListAllMyBuckets", "s3:ListMultiRegionAccessPoints",
      "s3:PutAccountPublic*", "shield:*", "sts:*", "support:*", "trustedadvisor:*",
      "waf-regional:*", "waf:*", "wafv2:*", "wellarchitected:*",
    ]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = var.allowed_regions
    }
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = [local.break_glass_arn]
    }
  }
}

resource "aws_organizations_policy" "baseline" {
  name        = "${var.project_name}-baseline-guardrails"
  description = "Deny leaving the org, tampering with security services, and root user activity."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.baseline.json

  lifecycle {
    precondition {
      condition     = local.scp_enabled
      error_message = "SCPs are not enabled on the organization root. Run: aws organizations enable-policy-type --root-id <root-id> --policy-type SERVICE_CONTROL_POLICY"
    }
  }
}

resource "aws_organizations_policy" "region_restriction" {
  name        = "${var.project_name}-region-restriction"
  description = "Deny regional API calls outside the allowed regions."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.region_restriction.json

  lifecycle {
    precondition {
      condition     = local.scp_enabled
      error_message = "SCPs are not enabled on the organization root. Run: aws organizations enable-policy-type --root-id <root-id> --policy-type SERVICE_CONTROL_POLICY"
    }
  }
}

resource "aws_organizations_policy_attachment" "baseline" {
  for_each  = var.all_ou_ids
  policy_id = aws_organizations_policy.baseline.id
  target_id = each.value
}

resource "aws_organizations_policy_attachment" "region_restriction" {
  for_each  = var.region_restricted_ou_ids
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = each.value
}
