Secure Multi-Cloud Infrastructure with Terraform & CI/CD

A production-ready cloud infrastructure blueprint built using Terraform, AWS, and GitHub Actions, with modular support for Azure and GCP. This project demonstrates real-world Cloud Engineering practices including secure VPC design, Infrastructure as Code, automated validation pipelines, and cloud-native security controls.

📌 Project Overview

This project provisions a secure, scalable, and automated cloud environment designed for web applications or microservices. It follows best practices used in enterprise cloud deployments, while remaining simple enough for startups and small teams to extend.

The architecture is built using modular Terraform, enabling predictable deployments across environments (dev, staging, prod) with consistent security, naming conventions, and configuration.

Key features include:

Private + public subnets across multiple Availability Zones

Secure inbound/outbound routing with optional NAT gateway

EC2 application tier in private subnets

Public ALB for traffic distribution

IAM roles and least-privilege access controls

CloudWatch logging and observability

CI/CD automation for Terraform validation, planning, and security scanning

🏗️ Architecture Diagram

(Add your diagram here once generated and save under diagrams/architecture.png)

High-Level Components

VPC with isolated network tiers

Public Subnets for load balancers, NAT gateway

Private Subnets for compute instances

Application Load Balancer (ALB) routing traffic to EC2

EC2 Compute Tier (or future ECS/EKS integration)

IAM Roles & Security Groups enforcing least-privilege and micro-segmentation

CloudWatch logs and monitoring

Terraform Backend using S3 + DynamoDB

🧱 Module Structure

The codebase is organized into logical Terraform modules:

modules/
  network_aws/        # VPC, subnets, routing, IGW, NAT
  security_aws/       # Security groups, IAM roles, instance profiles
  compute_aws/        # EC2, ALB, target groups, user data bootstrap
  observability_aws/  # CloudWatch logs, alarms, monitoring


Each module is reusable, versionable, and environment-agnostic.

🌎 Environments

Deployments are separated by environment (dev, prod, etc.) using:

environments/
  dev/
    main.tf
    variables.tf
    terraform.tfvars
    outputs.tf


This ensures:

Controlled rollouts

Consistent configuration

Easy scaling across multiple stages

🔐 Security Considerations

Security is built in from the start:

Private compute tier protects application instances

Least-privilege IAM policies restrict access to only what is needed

Security groups enforce segmented network boundaries

No direct SSH into EC2 (you can optionally add SSM Session Manager)

Logging and metrics enabled for audits and troubleshooting

Terraform state stored securely in S3 with DynamoDB locking

The repository includes Checkov security scanning in the CI/CD workflow to catch misconfigurations before deployment.

⚙️ CI/CD Pipeline (GitHub Actions)

Each pull request triggers the following:

Terraform Format

Terraform Init & Validate

Terraform Plan (with preview)

Security Scan (Checkov)

Apply step (optional, behind manual approval)

This ensures infrastructure changes are:

Tested

Documented

Secure

Reproducible

🚀 Deployment Guide
1. Set up Terraform Backend

Create:

S3 bucket for remote state

DynamoDB table for state locking
Example:

aws s3 mb s3://your-tf-state-bucket
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

2. Configure Environment Variables

In environments/dev/terraform.tfvars, define:

name                = "demo-dev"
vpc_cidr            = "10.10.0.0/16"
azs                 = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
enable_nat_gateway  = true

3. Deploy the Infrastructure
terraform init
terraform plan
terraform apply

📉 Cost Awareness

This architecture is optimized for portfolio use, but certain components incur cost:

NAT Gateway

Application Load Balancer

EC2 instance

You can disable NAT or downsize EC2 using variables to minimize charges.

📈 Future Enhancements (Optional)

You can extend this project to demonstrate additional skills:

Containerize the app and migrate to ECS Fargate

Add EKS (Kubernetes) deployment

Add Azure or GCP modules

Integrate AWS WAF, GuardDuty, or Security Hub

Add policy-as-code with OPA/Rego

Add Terraform unit tests with Terratest

📬 Contact

If you're reviewing this project as part of my Upwork portfolio, feel free to reach out.
I can deploy, automate, secure, or modernize your cloud environment based on your needs.

🚀 How to Run This (First Time)
1️⃣ Create backend resources (one-time)

aws s3 mb s3://your-tf-state-bucket
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

2️⃣ Deploy

cd environments/dev
terraform init
terraform plan
terraform apply


  

