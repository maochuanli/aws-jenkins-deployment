data  "aws_route53_zone" "sandbox" {
  name = "sandbox.qrious.co.nz"
}

resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "${var.vpc_prefix}-${var.env}-nat-eip"
    Customer = "Qrious"
    Environment = "${var.env}"
    Owner = "sre@qrious.co.nz"
    Project = "Qrious Jenkins CI"
  }
}

resource "aws_eip" "jenkins" {
  vpc = true
  tags = {
    Name = "${var.vpc_prefix}-${var.env}-jenkins-master-eip"
    Customer = "Qrious"
    Environment = "${var.env}"
    Owner = "sre@qrious.co.nz"
    Project = "Qrious Jenkins CI"
  }
}

resource "aws_route53_record" "jenkins" {
  zone_id = "${data.aws_route53_zone.sandbox.zone_id}"
  name    = "jenkins-${var.env}.${data.aws_route53_zone.sandbox.name}"
  type    = "A"
  ttl     = "300"

  records = [
    "${aws_eip.jenkins.public_ip}"
  ]
}
