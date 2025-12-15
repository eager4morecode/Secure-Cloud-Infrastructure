terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ---- REMOTE STATE (configure after bucket/table exist) ----
  backend "s3" {
    bucket         = "your-tf-state-bucket"
    key            = "cloud-iac/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# -------------------------
# Network
# -------------------------
module "network" {
  source = "../../modules/network_aws"

  name                 = var.name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.common_tags
}

# -------------------------
# Security
# -------------------------
module "security" {
  source = "../../modules/security_aws"

  name                     = var.name
  vpc_id                   = module.network.vpc_id
  app_port                 = var.app_port
  allowed_alb_ingress_cidrs = var.allowed_alb_ingress_cidrs
  enable_https_ingress     = false
  enable_ssh_sg            = false
  enable_s3_read_access    = false

  tags = local.common_tags
}

# -------------------------
# Compute
# -------------------------
module "compute" {
  source = "../../modules/compute_aws"

  name                  = var.name
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_id     = module.network.private_subnet_ids[0]

  alb_sg_id             = module.security.alb_security_group_id
  app_sg_id             = module.security.app_security_group_id
  instance_profile_name = module.security.iam_instance_profile_name

  instance_type = var.instance_type
  app_port      = var.app_port

  tags = local.common_tags
}

# -------------------------
# Locals
# -------------------------
locals {
  common_tags = {
    Environment = "dev"
    Owner       = "terraform"
    Project     = var.name
  }
}

