/* Security group for the nat server */
resource "aws_security_group" "bosh-inception" {
  name = "inception"
  description = "Security group for bosh-inception instances that allows SSH traffic from internet. Also allows outbound HTTP[S]"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    cidr_blocks = ["${aws_subnet.bosh_director.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    cidr_blocks = ["${aws_subnet.bosh_director.cidr_block}"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  tags {
    Name = "bosh-inception"
  }
}

/* Security group for the bosh network */
resource "aws_security_group" "bosh" {
  name = "bosh"
  description = "Security group for bosh-director instances"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    cidr_blocks = ["${aws_subnet.public.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    cidr_blocks = ["${aws_subnet.public.cidr_block}"]
  }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  tags {
    Name = "bosh"
  }
}