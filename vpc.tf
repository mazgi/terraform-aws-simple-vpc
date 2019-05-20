# --------------------------------
# VPC

resource "aws_vpc" "main" {
  cidr_block = "${var.cidr_block_vpc}"

  tags = {
    Name = "${var.basename}"
  }
}

resource "aws_vpc_dhcp_options" "this" {
  domain_name = "${join(" ", var.domain_names)}"
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.basename}"
  }
}

# --------------------------------
# NAT Gateways

resource "aws_eip" "for_nat_gateway" {
  count = "${length(keys(var.cidr_blocks_public_subnets))}"
  vpc   = true
}

resource "aws_nat_gateway" "main" {
  count = "${length(keys(var.cidr_blocks_public_subnets))}"

  depends_on = [
    "aws_internet_gateway.this",
    "aws_eip.for_nat_gateway",
  ]

  allocation_id = "${element(aws_eip.for_nat_gateway.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
}

# --------------------------------
# Public Subnets

resource "aws_subnet" "public" {
  count = "${length(keys(var.cidr_blocks_public_subnets))}"

  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(keys(var.cidr_blocks_public_subnets), count.index)}"
  availability_zone       = "${data.aws_region.current.name}${lookup(var.cidr_blocks_public_subnets, element(keys(var.cidr_blocks_public_subnets), count.index))}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.basename}-public-${data.aws_region.current.name}${lookup(var.cidr_blocks_public_subnets, element(keys(var.cidr_blocks_public_subnets), count.index))}"
  }
}

# --------------------------------
# Private Subnets

resource "aws_subnet" "private" {
  count = "${length(keys(var.cidr_blocks_private_subnets))}"

  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(keys(var.cidr_blocks_private_subnets), count.index)}"
  availability_zone       = "${data.aws_region.current.name}${lookup(var.cidr_blocks_private_subnets, element(keys(var.cidr_blocks_private_subnets), count.index))}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.basename}-private-${data.aws_region.current.name}${lookup(var.cidr_blocks_private_subnets, element(keys(var.cidr_blocks_private_subnets), count.index))}"
  }
}

# --------------------------------
# Route Tables

resource "aws_route_table" "this" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.this.id}"
  }

  tags = {
    Name = "${var.basename}-main-route-table"
  }
}

resource "aws_main_route_table_association" "this" {
  vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.this.id}"
}

resource "aws_route_table" "to_nat_gateway_for_private_subnets" {
  count = "${length(keys(var.cidr_blocks_private_subnets))}"

  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.main.*.id, count.index)}"
  }

  tags {
    Name = "${var.basename}-private-${count.index + 1}"
  }
}

resource "aws_route_table_association" "to_nat_gateway_for_private_subnets" {
  count = "${length(keys(var.cidr_blocks_private_subnets))}"

  route_table_id = "${element(aws_route_table.to_nat_gateway_for_private_subnets.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}
