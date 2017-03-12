output "jumpbox_ip" {
  value = "${aws_instance.jumpbox.0.public_ip}"
}

output "jumpbox_dns" {
  value = "${aws_instance.jumpbox.public_dns}"
}
