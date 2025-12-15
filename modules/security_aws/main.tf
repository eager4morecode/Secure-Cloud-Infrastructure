terraform {
  required_version = ">= 1.5.0"
}

locals {
  common_tags = merge(
    {
      "Project" = var.name
      "Managed" = "terraform"
    },
    var.tags
  )
}

# -------------------------
# Security Groups
# -------------------------

# ALB Security Group – internet-facing HTTP/HTTPS
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security group for public ALB"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-alb-sg"
    "Tier" = "public"
  })
}

# Allow HTTP (or app_port) from allowed CIDRs to ALB
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_alb_ingress_cidrs
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP/app traffic to ALB from allowed CIDRs"
}

# Optional HTTPS rule if you later front this with TLS
resource "aws_security_group_rule" "alb_ingress_https" {
  count             = var.enable_https_ingress ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_alb_ingress_cidrs
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS traffic to ALB from allowed CIDRs"
}

# Egress to anywhere (typical for ALB)
resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow all egress from ALB"
}

# -------------------------
# Application Security Group
# -------------------------

resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "Security group for application instances"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-app-sg"
    "Tier" = "private"
  })
}

# Only allow traffic from ALB SG to app_port
resource "aws_security_group_rule" "app_ingress_from_alb" {
  type                     = "inress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.app.id
  description              = "Allow app traffic from ALB only"
}

# Egress from app instances to anywhere (for updates, APIs, etc.)
resource "aws_security_group_rule" "app_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
  description       = "Allow all egress from app instances"
}

# -------------------------
# Optional SSH/Bastion Security Group
# -------------------------

resource "aws_security_group" "ssh" {
  count       = var.enable_ssh_sg ? 1 : 0
  name        = "${var.name}-ssh-sg"
  description = "Security group for SSH access (bastion or admin)"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-ssh-sg"
    "Tier" = "admin"
  })
}

resource "aws_security_group_rule" "ssh_ingress" {
  count = var.enable_ssh_sg ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_ingress_cidrs
  security_group_id = aws_security_group.ssh[0].id
  description       = "Allow SSH from trusted CIDRs"
}

resource "aws_security_group_rule" "ssh_egress" {
  count = var.enable_ssh_sg ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh[0].id
  description       = "Allow all egress from SSH/admin instances"
}

# -------------------------
# IAM Role + Instance Profile for EC2
# -------------------------

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Base policy: allow SSM, CloudWatch logs/metrics, and S3 read (optional)
data "aws_iam_policy_document" "base_ec2_policy" {
  statement {
    sid    = "SSMCore"
    effect = "Allow"

    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.enable_s3_read_access ? [1] : []
    content {
      sid    = "S3ReadOnly"
      effect = "Allow"

      actions = [
        "s3:GetObject",
        "s3:ListBucket"
      ]

      resources = ["*"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${var.name}-app-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_policy" "app_inline" {
  name   = "${var.name}-app-ec2-policy"
  policy = data.aws_iam_policy_document.base_ec2_policy.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "app_attach" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app_inline.arn
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.name}-app-ec2-profile"
  role = aws_iam_role.app.name
}
