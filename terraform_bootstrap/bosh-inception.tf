resource "aws_instance" "bosh-inception" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public.id}"
  security_groups = ["${aws_security_group.bosh-inception.id}"]
  key_name = "${aws_key_pair.deployer.key_name}"

  provisioner "local-exec" {
    command = "echo  ${aws_instance.bosh-inception.public_dns} > dns-info.txt"
  }

  provisioner "file" {
    connection {
      user = "ubuntu"
      host = "${aws_instance.bosh-inception.public_dns}"
      timeout = "1m"
      private_key = "${file("insecure-deployer")}" #/home/chii/workspace/bosh/makeaws/terraform_bootstrap/insecure-deployer"#
    }
    source = "bosh.pem"
    destination = "/home/ubuntu/bosh.pem"
  }

  provisioner "file" {
    connection {
      user = "ubuntu"
      host = "${aws_instance.bosh-inception.public_dns}"
      timeout = "1m"
      private_key = "${file("insecure-deployer")}" #/home/chii/workspace/bosh/makeaws/terraform_bootstrap/insecure-deployer"#
    }
    source = "install.sh"
    destination = "/home/ubuntu/install.sh"
  }

  provisioner "remote-exec" {
    connection {
      user = "ubuntu"
      host = "${aws_instance.bosh-inception.public_dns}"
      timeout = "5m"
      private_key = "${file("insecure-deployer")}"
    }
    inline = [
      "chmod +x install.sh",
      "./install.sh ${var.vpc_cidr} ${var.vpc_gw} ${var.bosh_ip} ${var.access_key} ${var.secret_key} ${aws_subnet.public.id}"
    ]
  }
  tags = {
    Name = "bosh-inception-vm-${count.index}"
  }
}
