output "alb_security_group_id" {
  description = "ID of the security group attached to the ALB."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "ID of the security group attached to application instances."
  value       = aws_security_group.app.id
}

output "ssh_security_group_id" {
  description = "ID of the optional SSH/admin security group (if created)."
  value       = length(aws_security_group.ssh) > 0 ? aws_security_group.ssh[0].id : null
}

output "iam_role_name" {
  description = "Name of the IAM role attached to application instances."
  value       = aws_iam_role.app.name
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2."
  value       = aws_iam_instance_profile.app.name
}
