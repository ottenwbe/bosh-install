/** jumpbox instance */
resource "aws_instance" "jumpbox" {
  ami             = "${lookup(var.amis, var.region)}"
  instance_type   = "t2.micro"
  subnet_id       = "${aws_subnet.public.id}"
  security_groups = ["${aws_security_group.bosh.id}", "${aws_security_group.vpc_nat.id}", "${aws_security_group.ssh.id}"]
  key_name        = "${aws_key_pair.deployer.key_name}"

  /* ensure that nat instance and network are up and running */
  depends_on = ["aws_instance.nat", "aws_subnet.bosh"]

  provisioner "local-exec" {
    command = "echo  ${aws_instance.jumpbox.public_dns} > dns-info.txt"
  }

  /** copy the bosh key to the jumpbox */
  provisioner "file" {
    connection {
      user        = "ubuntu"
      host        = "${aws_instance.jumpbox.public_dns}"
      timeout     = "1m"
      private_key = "${file("ssh/deployer.pem")}"
    }

    source      = "ssh/bosh.pem"
    destination = "/home/ubuntu/.ssh/bosh.pem"
  }

  provisioner "file" {
    connection {
      user        = "ubuntu"
      host        = "${aws_instance.jumpbox.public_dns}"
      timeout     = "1m"
      private_key = "${file("ssh/deployer.pem")}"
    }

    source      = "bin/install.sh"
    destination = "/home/ubuntu/install.sh"
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      host        = "${aws_instance.jumpbox.public_dns}"
      timeout     = "25m"
      private_key = "${file("ssh/deployer.pem")}"
    }

    inline = [
      "chmod +x install.sh",
      "./install.sh ${var.bosh_subnet_cidr} ${var.bosh_gw} ${var.bosh_ip} ${var.access_key} ${var.secret_key} ${aws_subnet.bosh.id} ~/.ssh/bosh.pem",
    ]
  }

  tags = {
    Name = "jumphost-vm-${count.index}"
  }
}
