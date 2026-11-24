output "root_id" { value = data.aws_organizations_organization.current.roots[0].id }
output "security_ou_id" { value = aws_organizations_organizational_unit.security.id }
output "shared_services_ou_id" { value = aws_organizations_organizational_unit.shared_services.id }
output "workloads_ou_id" { value = aws_organizations_organizational_unit.workloads.id }
output "sandbox_ou_id" { value = aws_organizations_organizational_unit.sandbox.id }
