/** internet access */
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

/** public subnet for the nat instance and the jumpbox */
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  availability_zone       = "${var.default_az}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.default"]

  tags {
    Name = "public-net"
  }
}

/** private network for the bosh managed vms */
resource "aws_subnet" "bosh" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.bosh_subnet_cidr}"
  availability_zone       = "${var.default_az}"
  map_public_ip_on_launch = false
  depends_on              = ["aws_instance.nat"]

  tags {
    Name = "bosh-net"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

resource "aws_route_table" "bosh" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "bosh" {
  subnet_id      = "${aws_subnet.bosh.id}"
  route_table_id = "${aws_route_table.bosh.id}"
}
