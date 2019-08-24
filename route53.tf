resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "${var.vpc_prefix}-nat-eip"
    Customer = "Qrious"
    Environment = "prod"
    Owner = "sre@qrious.co.nz"
    Project = "Qrious Jenkins CI"
  }
}

resource "aws_eip" "jenkins" {
  vpc = true
  tags = {
    Name = "${var.vpc_prefix}-jenkins-master-eip"
    Customer = "Qrious"
    Environment = "prod"
    Owner = "sre@qrious.co.nz"
    Project = "Qrious Jenkins CI"
  }
}

resource "aws_route53_zone" "sandbox" {
  name = "sandbox.qrious.co.nz"
}

resource "aws_route53_record" "jenkins" {
  zone_id = "${aws_route53_zone.sandbox.zone_id}"
  name    = "jenkins.sandbox.qrious.co.nz"
  type    = "A"
  ttl     = "300"

  records = [
    "${aws_eip.jenkins.public_ip}"
  ]
}

output "sandbox-zone-servers" {
  value = "${join(",", aws_route53_zone.sandbox.name_servers)}"
}