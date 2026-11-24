output "organization_root_id" { value = module.organization.root_id }
output "platform_log_bucket" { value = module.logging.log_bucket_name }
output "platform_vpc_id" { value = module.networking.vpc_id }
output "platform_engineer_role_arn" { value = module.iam_roles.platform_engineer_role_arn }
output "scp_baseline_policy_id" { value = module.service_control_policies.baseline_policy_id }
output "scp_region_restriction_policy_id" { value = module.service_control_policies.region_restriction_policy_id }
