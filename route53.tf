resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name        = "${var.vpc_prefix}-${var.env}-nat-eip"
    Customer    = "Qrious"
    Environment = "${var.env}"
    Owner       = "sre@qrious.co.nz"
    Project     = "Qrious Jenkins CI"
  }
}

resource "aws_eip" "jenkins" {
  vpc = true
  tags = {
    Name        = "${var.vpc_prefix}-${var.env}-jenkins-master-eip"
    Customer    = "Qrious"
    Environment = "${var.env}"
    Owner       = "sre@qrious.co.nz"
    Project     = "Qrious Jenkins CI"
  }
}
