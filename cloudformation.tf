data "aws_cloudformation_stack" "aviatrix" {
  name = "${var.vpc_prefix}-vpc-cf"
}

data "aws_eip" "jenkins_public_ip" {
  public_ip = "${var.jenkins_public_ip}"
}
