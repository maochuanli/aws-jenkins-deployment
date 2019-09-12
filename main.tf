terraform {
  backend "s3" {
    role_arn             = "arn:aws:iam::130552128005:role/jenkins-assume-role-from-sandbox"
    key                  = "terraform.tfstate"
    dynamodb_table       = "Terraform-State-Lock-Table"
    bucket               = "terraform.state.files.qrious.co.nz"
    region               = "ap-southeast-2"
    workspace_key_prefix = "Qrious-Jenkins-Project"
  }
}

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_no}:role/jenkins-assume-role-from-sandbox"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.vpc_prefix}-${var.env}-igw"
    Customer    = "Qrious"
    Environment = "${var.env}"
    Owner       = "sre@qrious.co.nz"
    Project     = "Qrious Jenkins CI"
  }
}


resource "aws_key_pair" "ec2" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}


# Create a subnet to launch our instances into
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.vpc_prefix}-${var.env}-public-subnet"
    Customer    = "Qrious"
    Environment = "${var.env}"
    Owner       = "sre@qrious.co.nz"
    Project     = "Qrious Jenkins CI"
  }
}

# Create a subnet to launch our slaves into
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.private_subnet_cidr}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.vpc_prefix}-${var.env}-private-subnet"
    Customer    = "Qrious"
    Environment = "${var.env}"
    Owner       = "sre@qrious.co.nz"
    Project     = "Qrious Jenkins CI"
  }
}

//public subnet route table
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  #  route {
  #    cidr_block = "10.201.247.0/24"
  #    network_interface_id = "${data.aws_cloudformation_stack.aviatrix.outputs["AviatrixENIId"]}"
  #  }

  tags = {
    Name        = "${var.vpc_prefix}-${var.env}-public-subnet-route-table"
    Customer    = "Qrious"
    Environment = "${var.env}"
    Owner       = "sre@qrious.co.nz"
    Project     = "Qrious Jenkins CI"
  }

}
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"

  tags = {
    Name        = "${var.vpc_prefix}-${var.env}-nat-gw"
    Customer    = "Qrious"
    Environment = "${var.env}"
    Owner       = "sre@qrious.co.nz"
    Project     = "Qrious Jenkins CI"
  }
}

//private subnet route table
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }

  #  route {
  #    cidr_block = "10.201.247.0/24"
  #    network_interface_id = "${data.aws_cloudformation_stack.aviatrix.outputs["AviatrixENIId"]}"
  #  }

  tags = {
    Name        = "${var.vpc_prefix}-${var.env}-private-subnet-route-table"
    Customer    = "Qrious"
    Environment = "prod"
    Owner       = "sre@qrious.co.nz"
    Project     = "Qrious Jenkins CI"
  }
}
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "master" {
  name        = "jenkins-master-security-group-${var.env}"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.main.id}"

  # SSH access from Spark Network Only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["146.171.246.0/24", "146.171.254.96/32", "146.171.254.99/32", "203.96.123.0/24"]
  }

  # SSH access from Sandbox NAT GW
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["13.210.31.135"]
  }

  # HTTPS access from Spark Network Only
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["146.171.246.0/24", "146.171.254.96/32", "146.171.254.99/32", "203.96.123.0/24"]
  }

  # HTTP access from the VPC, only for Let's Encrypt to work for a short period.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from the Bitbucket
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["18.205.93.0/25", "18.234.32.128/25", "13.52.5.0/25", "34.199.54.113/32", "34.232.25.90/32", "34.232.119.183/32", "34.236.25.177/32", "35.171.175.212/32", "52.54.90.98/32", "52.202.195.162/32", "52.203.14.55/32", "52.204.96.37/32", "34.218.156.209/32", "34.218.168.212/32", "52.41.219.63/32", "35.155.178.254/32", "35.160.177.10/32", "34.216.18.129/32"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# the instances over SSH and HTTP
resource "aws_security_group" "slave" {
  name        = "jenkins-slave-security-group-${var.env}"
  description = "Used in the private subnet"
  vpc_id      = "${aws_vpc.main.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.master.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id            = "${aws_subnet.public_subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.master_instance_profile.id}"

  tags = {
    Name        = "${var.vpc_prefix}-${var.env}-jenkins-master"
    Customer    = "Qrious"
    Environment = "${var.env}"
    Owner       = "sre@qrious.co.nz"
    Project     = "Qrious Jenkins CI"
    Downtime    = "default"
  }

  user_data = <<DATA
#!/bin/bash
touch /root/init.txt


DATA

}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.jenkins.id}"
  allocation_id = "${aws_eip.jenkins.id}"
}

resource "null_resource" "config" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user        = "admin"
    agent       = false
    host        = "${aws_eip.jenkins.public_ip}"
    private_key = "${file(var.key_file_path)}"
  }
  depends_on = ["aws_eip_association.eip_assoc"]
  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "echo who am i: `whoami`",
      "echo current DIR: `pwd`",
      "echo docker run -it --rm hello-world"
    ]
  }
}

resource "local_file" "ansible-config" {
  content  = <<DATA
---
jenkins_public_ip: ${aws_eip.jenkins.public_ip}
jenkins_dns_name: jenkins.qrious.co.nz
reset_docker: true
#Default Debian custom image
slave_ami_id: ami-0019173738c29be04
slave_subnet_id: ${aws_subnet.private_subnet.id}
slave_security_group_name: ${aws_security_group.slave.name}
slave_private_key_file_path: ${var.key_file_path}
slave_instance_profile_arn: ${aws_iam_instance_profile.slave_instance_profile.arn}

DATA
  filename = "${path.module}/ansible/${var.env}.ansible.config.yml"
}
