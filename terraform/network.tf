################ NETWORK ################################
# Create custom VPC
resource "aws_vpc" "my_custom_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-custom-vpc-for-ecs"
  }
}

# Create Public Subnet 1
resource "aws_subnet" "my_custom_subnet_public_a" {
  vpc_id                  = aws_vpc.my_custom_vpc.id
  cidr_block              = var.public_subnet_a_cidr_block
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-custom-subnet-public-a"
  }
}

# Create Public Subnet 2
resource "aws_subnet" "my_custom_subnet_public_b" {
  vpc_id                  = aws_vpc.my_custom_vpc.id
  cidr_block              = var.public_subnet_b_cidr_block
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-custom-subnet-public-b"
  }
}

# Create Private Subnet 1
resource "aws_subnet" "my_custom_subnet_private_a" {
  vpc_id                  = aws_vpc.my_custom_vpc.id
  cidr_block              = var.private_subnet_a_cidr_block
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false
  tags = {
    Name = "my-custom-subnet-private-a"
  }
}

# Create Private Subnet 2
resource "aws_subnet" "my_custom_subnet_private_b" {
  vpc_id                  = aws_vpc.my_custom_vpc.id
  cidr_block              = var.private_subnet_b_cidr_block
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false
  tags = {
    Name = "my-custom-subnet-private-b"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_custom_igw" {
  vpc_id = aws_vpc.my_custom_vpc.id
  tags = {
    Name = "my-custom-igw"
  }
}

#route table-public
resource "aws_route_table" "my_custom_route_table_public" {
  vpc_id = aws_vpc.my_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_custom_igw.id
  }

  route {
    cidr_block = aws_vpc.my_custom_vpc.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "my-custom-route-table-public"
  }
}

# public route table association for public subnet a
resource "aws_route_table_association" "public_subnet_a" {
  subnet_id      = aws_subnet.my_custom_subnet_public_a.id
  route_table_id = aws_route_table.my_custom_route_table_public.id
}

# public route table association for public subnet b
resource "aws_route_table_association" "public_subnet_b" {
  subnet_id      = aws_subnet.my_custom_subnet_public_b.id
  route_table_id = aws_route_table.my_custom_route_table_public.id
}


# create elastic IP for NAT gateway
resource "aws_eip" "my_custom_eip" {
  domain   = "vpc"
}

# create NAT gateway
resource "aws_nat_gateway" "my_custom_nat_gateway" {
  allocation_id = aws_eip.my_custom_eip.id
  subnet_id     = aws_subnet.my_custom_subnet_public_a.id
  tags = {
    Name = "my-custom-nat-gateway"
  }
}

#route table-private
resource "aws_route_table" "my_custom_route_table_private" {
  vpc_id = aws_vpc.my_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my_custom_nat_gateway.id
  }

  route {
    cidr_block = aws_vpc.my_custom_vpc.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "my-custom-route-table-private"
  }
}

# private route table association for private subnet a
resource "aws_route_table_association" "private_subnet_a" {
  subnet_id      = aws_subnet.my_custom_subnet_private_a.id
  route_table_id = aws_route_table.my_custom_route_table_private.id
}

# private route table association for private subnet b
resource "aws_route_table_association" "private_subnet_b" {
  subnet_id      = aws_subnet.my_custom_subnet_private_b.id
  route_table_id = aws_route_table.my_custom_route_table_private.id
}


# Create alb Security Group
resource "aws_security_group" "my_custom_alb_sg" {
  name        = "my-custom-alb-sg-1"
  description = "This will allow traffic on port 80 from anywhere"
  vpc_id      = aws_vpc.my_custom_vpc.id
}

# ingress rule 1
resource "aws_security_group_rule" "my_custom_alb_ingress_rule_1" {
  security_group_id = aws_security_group.my_custom_alb_sg.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

# ingress rule 2
resource "aws_security_group_rule" "my_custom_alb_ingress_rule_2" {
  security_group_id = aws_security_group.my_custom_alb_sg.id
  type        = "ingress"
  from_port   = 0
  to_port     = 65535  
  protocol    = "-1"    
  cidr_blocks = ["0.0.0.0/0"]
}

#default egress rule
resource "aws_vpc_security_group_egress_rule" "my_custom_alb_egress_rule_1" {
  security_group_id = aws_security_group.my_custom_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create ecs Security Group #####################################
resource "aws_security_group" "my_custom_ecs_sg" {
  name        = "my-custom-sg-for-ecs"
  description = "This will allow traffic from alb sg"
  vpc_id      = aws_vpc.my_custom_vpc.id
}

resource "aws_security_group_rule" "ecs_to_alb_ingress_rule" {
  security_group_id = aws_security_group.my_custom_ecs_sg.id  
  type              = "ingress"
  from_port         = var.container_port
  to_port           = var.container_port
  protocol          = "tcp"
  source_security_group_id = aws_security_group.my_custom_alb_sg.id  
}

#default egress rule
resource "aws_vpc_security_group_egress_rule" "my_custom_egress_rule_1" {
  security_group_id = aws_security_group.my_custom_ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
