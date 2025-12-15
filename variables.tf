variable "name" {
  description = "Name prefix used for tagging and resource naming."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of availability zones to use. Length must match subnet CIDR lists."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets. Length must match azs."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets. Length must match azs."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to provision a NAT gateway for outbound internet access from private subnets."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "If true, creates a single NAT gateway in the first public subnet to save cost."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
