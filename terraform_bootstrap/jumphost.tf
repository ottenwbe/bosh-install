resource "aws_instance" "jumphost" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public.id}"
  security_groups = ["${aws_security_group.bosh-inception.id}"]
  key_name = "${aws_key_pair.deployer.key_name}"

  depends_on = ["aws_instance.nat"]

  provisioner "local-exec" {
    command = "echo  ${aws_instance.jumphost.public_dns} > dns-info.txt"
  }

  provisioner "file" {
    connection {
      user = "ubuntu"
      host = "${aws_instance.jumphost.public_dns}"
      timeout = "1m"
      private_key = "${file("insecure-deployer")}"
    }
    source = "bosh.pem"
    destination = "/home/ubuntu/bosh.pem"
  }

  provisioner "file" {
    connection {
      user = "ubuntu"
      host = "${aws_instance.jumphost.public_dns}"
      timeout = "1m"
      private_key = "${file("insecure-deployer")}"
    }
    source = "install.sh"
    destination = "/home/ubuntu/install.sh"
  }

  provisioner "remote-exec" {
    connection {
      user = "ubuntu"
      host = "${aws_instance.jumphost.public_dns}"
      timeout = "25m"
      private_key = "${file("insecure-deployer")}"
    }
    inline = [
      "chmod +x install.sh",
      "./install.sh ${var.bosh_subnet_cidr} ${var.bosh_gw} ${var.bosh_ip} ${var.access_key} ${var.secret_key} ${aws_subnet.bosh_director.id} ~/bosh.pem"
    ]
  }
  tags = {
    Name = "bosh-inception-vm-${count.index}"
  }
}
