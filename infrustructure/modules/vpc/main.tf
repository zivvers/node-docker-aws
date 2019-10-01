# ---------------------------------------------------------------------------------------------------------------------
# Create a VPC which allocates IP addresses across 3 availability zones.
#
# A public and private subnet is created for each AZ. The private subnet is twice the size
# of the public subnet, since your publicly-accessible hosts will likely be far fewer in 
# number than your internal-only ones.
#
# Spare IP addresses are left at each level to accomodate unknown future use-cases.
#
#
# IP Address layout:
#
# 10.0.0.0/16:
#     10.0.0.0/18 — AZ A
#         10.0.0.0/19   — Private
#         10.0.32.0/20  — Public
#         10.0.48.0/20  — Spare
#     10.0.64.0/18 — AZ B
#         10.0.64.0/19  — Private
#         10.0.96.0/20  — Public
#         10.0.112.0/20 - Spare
#     10.0.128.0/18 — AZ C
#         10.0.128.0/19 — Private
#         10.0.160.0/20 — Public
#         10.0.176.0/20 - Spare
#     10.0.192.0/18 — Spare
#
#
# Spare IP addresses can be allocated like so:
#
# 10.0.0.0/18 — AZ A
#       10.0.0.0/19 — Private
#       10.0.32.0/19
#               10.0.32.0/20 — Public
#               10.0.48.0/20
#                   10.0.48.0/21 — Protected
#                   10.0.56.0/21 — Spare
#
#
# Total IP addresses allocated:
#
# 16-bit: 65534 addresses
# 18-bit: 16382 addresses
# 19-bit: 8190 addresses
# 20-bit: 4094 addresses
#
#
# Inspired by https://medium.com/aws-activate-startup-blog/practical-vpc-design-8412e1a18dcc
# ---------------------------------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "available" {}

resource "aws_subnet" "availability_zone_1_private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.0.0/19"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "availability_zone_1_public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.32.0/20"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "availability_zone_2_private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.64.0/19"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "availability_zone_2_public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.96.0/20"
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "availability_zone_3_private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.128.0/19"
  availability_zone = "${data.aws_availability_zones.available.names[2]}"

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "availability_zone_3_public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.160.0/20"
  availability_zone       = "${data.aws_availability_zones.available.names[2]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE INTERNET GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ROUTING TABLES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_route_table_association" "public_az_1" {
  subnet_id      = "${aws_subnet.availability_zone_1_public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_az_2" {
  subnet_id      = "${aws_subnet.availability_zone_2_public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_az_3" {
  subnet_id      = "${aws_subnet.availability_zone_3_public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR INBOUND SSH
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "inbound_ssh" {
  name        = "${var.name}-inbound-ssh"
  description = "Security group for public instances which want to enable SSH"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "inbound_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = flatten([var.ip_address_for_ssh])
  security_group_id = "${aws_security_group.inbound_ssh.id}"
}
