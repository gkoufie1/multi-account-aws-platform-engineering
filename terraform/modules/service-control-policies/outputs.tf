output "baseline_policy_id" {
  value = aws_organizations_policy.baseline.id
}

output "region_restriction_policy_id" {
  value = aws_organizations_policy.region_restriction.id
}
