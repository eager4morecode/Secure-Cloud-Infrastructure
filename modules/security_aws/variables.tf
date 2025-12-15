variable "name" {
  description = "Name prefix used for tagging and resource naming."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which to create security groups."
  type        = string
}

variable "app_port" {
  description = "Port used by the application behind the ALB."
  type        = number
  default     = 80
}

variable "allowed_alb_ingress_cidrs" {
  description = "List of CIDR blocks allowed to reach the ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_https_ingress" {
  description = "Whether to allow inbound HTTPS (443) to the ALB."
  type        = bool
  default     = false
}

variable "enable_ssh_sg" {
  description = "Whether to create a separate security group for SSH/admin access."
  type        = bool
  default     = false
}

variable "ssh_ingress_cidrs" {
  description = "CIDR blocks allowed to SSH (used when enable_ssh_sg = true)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_s3_read_access" {
  description = "Whether the EC2 IAM role should have S3 read permissions."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
