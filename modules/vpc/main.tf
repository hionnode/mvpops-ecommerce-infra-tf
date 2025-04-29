# modules/vpc/main.tf

# --- VPC ---
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(var.tags, {
    Name = var.name
  })
}

# --- Subnets ---
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true # Public subnets typically need this
  tags = merge(var.tags, var.public_subnet_tags, {
    Name = "${var.name}-public-${var.azs[count.index]}"
  })
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(var.tags, var.private_subnet_tags, {
    Name = "${var.name}-private-${var.azs[count.index]}"
  })
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = var.name
  })
}

# --- NAT Gateway(s) ---
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnets)) : 0
  domain = "vpc" # Changed from tags = var.tags due to deprecation, use 'domain' instead
  tags = merge(var.tags, {
     Name = var.single_nat_gateway ? "${var.name}-nat" : "${var.name}-nat-${var.azs[count.index]}"
  })
}


resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnets)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id # Place NAT GW in public subnet
  tags = merge(var.tags, {
     Name = var.single_nat_gateway ? "${var.name}-nat" : "${var.name}-nat-${var.azs[count.index]}"
  })
  depends_on = [aws_internet_gateway.this] # Ensure IGW exists first
}

# --- Route Tables ---
# Public Route Table (associated with public subnets, routes to IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name}-public"
  })
}
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables (one per AZ, associated with private subnets, routes to NAT GW)
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? length(var.private_subnets) : 0 # Only if NAT is enabled
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name}-private-${var.azs[count.index]}"
  })
}
resource "aws_route" "private_nat" {
  count                  = var.enable_nat_gateway ? length(var.private_subnets) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  # Route to the single NAT GW or the corresponding AZ's NAT GW
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
}
resource "aws_route_table_association" "private" {
  count          = var.enable_nat_gateway ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Note: This example omits NACLs, Flow Logs, complex routing scenarios for brevity.