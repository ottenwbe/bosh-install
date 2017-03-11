resource "aws_instance" "nat" {
  ami = "${lookup(var.amis, var.region)}" #TODO: find nat instance
  availability_zone = "${var.default_az}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.bosh.id}","${aws_security_group.vpc_nat.id}"]
  subnet_id = "${aws_subnet.public.id}"
  associate_public_ip_address = true
  source_dest_check = false
  key_name = "${aws_key_pair.deployer.key_name}"

  connection {
    user = "ubuntu"
    timeout = "5m"
    private_key = "${file("insecure-deployer")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "sudo apt -y  upgrade",
      "sudo iptables -t nat -A POSTROUTING -j MASQUERADE"
      ]
  }

  tags {
    Name = "VPC NAT"
  }
}

resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc = true
}

