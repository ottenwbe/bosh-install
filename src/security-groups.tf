resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "SSH access to instances from the internet"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "ssh sg"
  }
}

/* Security group for the nat instance */
resource "aws_security_group" "vpc_nat" {
  name        = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "NATSG"
  }
}

resource "aws_security_group" "bosh" {
  name        = "bosh"
  description = "Security group for bosh vms"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  tags {
    Name = "bosh sg"
  }
}
