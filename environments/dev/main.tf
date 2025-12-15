module "network" {
  source = "../../modules/network_aws"

  name                = "demo-dev"
  vpc_cidr            = "10.10.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "Environment" = "dev"
  }
}
module "security" {
  source = "../../modules/security_aws"

  name                     = "demo-dev"
  vpc_id                   = module.network.vpc_id
  app_port                 = 80
  allowed_alb_ingress_cidrs = ["0.0.0.0/0"]  # tighten for real clients if needed
  enable_https_ingress     = false
  enable_ssh_sg            = false          # true if you want SSH SG
  enable_s3_read_access    = true

  tags = {
    "Environment" = "dev"
  }
}
module "compute" {
  source = "../../modules/compute_aws"

  name                = "demo-dev"
  vpc_id              = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  private_subnet_id   = module.network.private_subnet_ids[0]

  alb_sg_id           = module.security.alb_security_group_id
  app_sg_id           = module.security.app_security_group_id
  instance_profile_name = module.security.iam_instance_profile_name

  instance_type       = "t3.micro"
  app_port            = 80

  tags = {
    Environment = "dev"
  }
}

