resource "aws_nat_gateway" "nat"{
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public.id}"
}


resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.public_subnet_cidr}"
  availability_zone = "${var.default_az}"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.default"]
  tags {
    Name = "bosh-inception"
  }
}

resource "aws_subnet" "bosh_director" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.bosh_subnet_cidr}"
  availability_zone = "${var.default_az}"
  map_public_ip_on_launch = false
  depends_on = ["aws_internet_gateway.default"]
  tags {
    Name = "bosh-director"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}


resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "bosh" {
  subnet_id = "${aws_subnet.bosh_director.id}"
  route_table_id = "${aws_route_table.public.id}"
}


resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "eu-west-1a-private" {
  subnet_id = "${aws_subnet.bosh_director.id}"
  route_table_id = "${aws_route_table.private.id}"
}