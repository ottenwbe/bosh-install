output "bosh_ip" {
  value = "${aws_instance.jumphost.0.public_ip}"
}

output "bosh_dns" {
  value = "${aws_instance.jumphost.public_dns}"
}