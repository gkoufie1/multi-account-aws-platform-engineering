# Multi-Account AWS Platform Engineering Environment

This project demonstrates a production-style AWS multi-account platform engineering foundation using Terraform and GitHub Actions.

## Business Problem
Organizations often start AWS adoption with one account. Over time, development, production, security, and shared services resources become mixed together. This creates governance gaps, security risk, unclear ownership, and difficult auditing.

## Solution
Use Terraform to define a multi-account AWS platform foundation with AWS Organizations, Organizational Units, account baselines, IAM roles, centralized logging, detective security controls (GuardDuty, Security Hub, AWS Config), preventive guardrails (Service Control Policies), and standardized networking patterns.

## Business Value
- Stronger governance and separation of duties
- Improved security and compliance readiness
- Repeatable account vending and baseline controls
- Standardized network and IAM patterns
- Better platform engineering maturity

## What Has Been Achieved
This is not just code on paper. The platform has been **deployed to a real AWS account and verified**.

**1. Built the organization's structure.**
Turned a single AWS account into the management account of an AWS Organization, and created four folders (Organizational Units) for different kinds of work: **Security**, **Shared Services**, **Workloads** (dev and prod) and **Sandbox** (experiments).

**2. Set rules nobody can break.**
Wrote two Service Control Policies and attached them to the folders. Any account placed in those folders automatically:
- cannot leave the organization
- cannot switch off the security tools or the audit trail
- cannot use the all-powerful "root" login
- can only work in approved AWS regions (Workloads and Sandbox)

A single break-glass admin role is exempt so problems can still be fixed.

**3. Switched on security monitoring.**
- **CloudTrail** records every action taken in the account, across all regions, into an encrypted, private, versioned storage bucket.
- **GuardDuty** watches for suspicious activity such as compromised credentials or unusual API calls.
- **AWS Config** keeps a history of every resource and how it has changed.
- **Security Hub** collects the security findings in one place.

**4. Created standard access roles.**
A **Platform Engineer** role that can build, and a **Read-Only Auditor** role that can only look, so people get the access their job needs and nothing more.

**5. Laid down a network.**
A VPC with public and private subnets spread across two availability zones, ready for applications.

**6. Kept costs under control.**
- A monthly **budget alert**.
- Security Hub's built-in compliance checklists are **off by default**. They were the biggest ongoing cost, and they can be switched on with one setting when needed.
- Storage buckets are set to **clean themselves up**, so the whole environment can be torn down with one command and nothing is left behind billing.

**7. Made it safe to run.**
- Terraform is **locked to one approved AWS account**, so it cannot accidentally change the wrong account.
- Terraform **refuses to start** if a prerequisite is missing (for example SCPs not enabled) and says exactly how to fix it.
- Account IDs and state files are kept **out of Git**.
- Every code change is automatically **format-checked and validated** by GitHub Actions.

**Result:** 44 AWS resources deployed from code in a single `terraform apply`. A follow-up `terraform plan` confirms that what is running in AWS exactly matches the code.

### Not done yet
- **Member accounts** (Security, Shared Services, Dev, Prod) are defined in code but not yet created, so the folders are currently empty and the rules have no accounts to restrict yet.
- **Centralized logging** in a dedicated Security account (this needs the member accounts first).
- **Single sign-on** through IAM Identity Center, so people log in once and pick which account to work in.

## Repository Structure
```text
.github/workflows/platform.yml
scripts/install-tools.sh
scripts/validate.sh
terraform/environments/dev
terraform/modules/organization
terraform/modules/account-baseline
terraform/modules/iam-roles
terraform/modules/networking
terraform/modules/logging
terraform/modules/security-guardrails
terraform/modules/service-control-policies
terraform/modules/budget
docs/youtube-walkthrough.md
docs/interview-explanation.md
docs/architecture.md
```

## Service Control Policies
The `service-control-policies` module adds preventive guardrails to member accounts:

| Policy | Attached to | What it does |
|---|---|---|
| `baseline-guardrails` | All OUs | Denies leaving the organization, disabling CloudTrail / GuardDuty / Config / Security Hub, and any root-user activity |
| `region-restriction` | Workloads, Sandbox | Denies regional API calls outside `allowed_regions` (default `us-east-1`, `us-west-2`) |

The `OrganizationAccountAccessRole` is exempt so administrators can still fix things. SCPs never apply to the management account.

**Prerequisite:** SCPs must be enabled on the organization root (Terraform checks this and fails with the command to run):
```bash
aws organizations enable-policy-type --root-id <root-id> --policy-type SERVICE_CONTROL_POLICY
```

## Quick Start
```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars   # set your AWS account ID
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

> Important: Creating AWS Organization accounts can affect billing and may require payer-account permissions. The included configuration is designed as a portfolio/learning-ready foundation and can be adapted for production.
