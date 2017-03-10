resource "aws_instance" "nat" {
  ami = "${lookup(var.amis, var.region)}" #TODO: find nat instance
  availability_zone = "${var.default_az}"
  instance_type = "t2.small"
  vpc_security_group_ids = ["${aws_security_group.nat.id}"]
  subnet_id = "${aws_subnet.public.id}"
  associate_public_ip_address = true
  source_dest_check = false

  tags {
    Name = "VPC NAT"
  }
}

resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc = true
}

