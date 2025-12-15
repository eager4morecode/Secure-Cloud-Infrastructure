output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = module.compute.alb_dns_name
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = module.compute.instance_id
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.network.vpc_id
}
