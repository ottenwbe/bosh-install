resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = "${file("insecure-deployer.pub")}"
}

/*resource "aws_key_pair" "bosh" {
  key_name = "bosh"
  public_key = "${file("bosh.pub")}"
}*/