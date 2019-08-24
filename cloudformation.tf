data "aws_cloudformation_stack" "aviatrix" {
  name = "${var.vpc_prefix}-vpc-cf"
}

