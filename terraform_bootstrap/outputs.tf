output "bosh_ip" {
  value = "${aws_instance.bosh-inception.0.public_ip}"
}

output "bosh_dns" {
  value = "${aws_instance.bosh-inception.public_dns}"
}