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
# VPC
# -------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-vpc"
  })
}

# -------------------------
# Internet Gateway
# -------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-igw"
  })
}

# -------------------------
# Public Subnets
# -------------------------
resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-public-${each.key}"
    "Tier" = "public"
  })
}

# -------------------------
# Private Subnets
# -------------------------
resource "aws_subnet" "private" {
  for_each = {
    for idx, cidr in var.private_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-private-${each.key}"
    "Tier" = "private"
  })
}

# -------------------------
# NAT Gateway (optional, cost-conscious)
# -------------------------

# Single NAT EIP (one NAT in first public subnet by default)
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.public)[0].id

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-nat-gw"
  })
}

# (Optional) Pattern for multiple NAT gateways (not enabled by default)
# You can extend this later if you want NAT per AZ.

# -------------------------
# Route Tables
# -------------------------

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private route table (shared for all private subnets for now)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    "Name" = "${var.name}-private-rt"
  })
}

resource "aws_route" "private_outbound" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
