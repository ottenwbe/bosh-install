output "jumpbox_ip" {
  value = "${aws_instance.jumpbox.public_ip}"
}

output "jumpbox_dns" {
  value = "${aws_instance.jumpbox.public_dns}"
}

output "bosh_subnet_cidr" {
  value = "${var.bosh_subnet_cidr}"
}

output "bosh_gw" {
  value = "${var.bosh_gw}"
}

output "bosh_ip" {
  value = "${var.bosh_ip}"
}

output "bosh_subnet" {
  value = "${aws_subnet.bosh.id}"
}
