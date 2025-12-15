variable "name" {
  description = "Name prefix used for tagging and resource naming."
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID where the target group will live."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the ALB."
  type        = list(string)
}

variable "private_subnet_id" {
  description = "A private subnet ID to place the EC2 instance."
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID for the ALB."
  type        = string
}

variable "app_sg_id" {
  description = "Security group ID for the application instance(s)."
  type        = string
}

variable "ssh_sg_id" {
  description = "Optional SSH/admin SG ID to add to the instance. Set to null to disable."
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "IAM instance profile name for EC2."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size in GB."
  type        = number
  default     = 20
}

variable "key_name" {
  description = "Optional EC2 key pair name. Leave null to avoid SSH access."
  type        = string
  default     = null
}

variable "ami_id" {
  description = "Optional AMI override. If null, uses latest Amazon Linux 2023."
  type        = string
  default     = null
}

variable "app_port" {
  description = "Application port on the instance."
  type        = number
  default     = 80
}

variable "listener_port" {
  description = "ALB listener port."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path for the ALB target group."
  type        = string
  default     = "/"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB."
  type        = bool
  default     = false
}
