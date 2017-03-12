/** key for deployment of jumpbox and nat */
resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = "${file("ssh/deployer.pub")}"
}

/** key for bosh */
resource "aws_key_pair" "bosh" {
  key_name = "bosh"
  public_key = "${file("ssh/bosh.pub")}"
}

