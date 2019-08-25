
# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "public_subnet" {
  #name = "${var.vpc_prefix}-public-subnet"
  vpc_id                  = "${data.aws_cloudformation_stack.aviatrix.outputs["VPCId"]}"
  cidr_block              = "${var.public_subnet_cidr}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_prefix}-public-subnet"
    Customer = "Qrious"
    Environment = "prod"
    Owner = "sre@qrious.co.nz"
    Project = "Qrious Jenkins CI"
  }
}

# Create a subnet to launch our slaves into
resource "aws_subnet" "private_subnet" {
  #name = "${var.vpc_prefix}-private-subnet"
  vpc_id                  = "${data.aws_cloudformation_stack.aviatrix.outputs["VPCId"]}"
  cidr_block              = "${var.private_subnet_cidr}"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_prefix}-private-subnet"
    Customer = "Qrious"
    Environment	= "prod"
    Owner = "sre@qrious.co.nz"
    Project = "Qrious Jenkins CI"
  }
}

//public subnet route table
resource "aws_route_table" "public_route_table" {
  vpc_id = "${data.aws_cloudformation_stack.aviatrix.outputs["VPCId"]}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${data.aws_cloudformation_stack.aviatrix.outputs["InternetGatewayId"]}"
  }

  route {
    cidr_block = "10.201.247.0/24"
    network_interface_id = "${data.aws_cloudformation_stack.aviatrix.outputs["AviatrixENIId"]}"
  }

  tags = {
    Name = "${var.vpc_prefix}-public-subnet-route-table"
    Customer = "Qrious"
    Environment	= "prod"
    Owner = "sre@qrious.co.nz"
    Project = "Qrious Jenkins CI"
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
    Name = "${var.vpc_prefix}-nat-gw"
    Customer = "Qrious"
    Environment	= "prod"
    Owner = "sre@qrious.co.nz"
    Project = "Qrious Jenkins CI"
  }
}

//private subnet route table
resource "aws_route_table" "private_route_table" {
  vpc_id = "${data.aws_cloudformation_stack.aviatrix.outputs["VPCId"]}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }

  route {
    cidr_block = "10.201.247.0/24"
    network_interface_id = "${data.aws_cloudformation_stack.aviatrix.outputs["AviatrixENIId"]}"
  }

  tags = {
    Name = "${var.vpc_prefix}-private-subnet-route-table"
    Customer = "Qrious"
    Environment	= "prod"
    Owner = "sre@qrious.co.nz"
    Project = "Qrious Jenkins CI"
  }
}
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "master" {
  name        = "jenkins-master-security-group"
  description = "Used in the terraform"
  vpc_id      = "${data.aws_cloudformation_stack.aviatrix.outputs["VPCId"]}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_cloudformation_stack.aviatrix.outputs["VPCCidrBlock"]}"]
  }

  # HTTPS access from the VPC
  ingress {
    from_port   = 443

    to_port     = 443
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

# the instances over SSH and HTTP
resource "aws_security_group" "slave" {
  name        = "jenkins-slave-security-group"
  description = "Used in the private subnet"
  vpc_id      = "${data.aws_cloudformation_stack.aviatrix.outputs["VPCId"]}"

  # HTTPS access from the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_cloudformation_stack.aviatrix.outputs["VPCCidrBlock"]}"]
  }

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
  subnet_id = "${aws_subnet.public_subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.master_instance_profile.id}"

  tags = {
    Name = "${var.vpc_prefix}-jenkins-master"
    Customer = "Qrious"
    Environment = "prod"
    Owner = "sre@qrious.co.nz"
    Project = "Qrious Jenkins CI"
    Downtime = "default"
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
    user = "admin"
    agent = false
    host = "${aws_eip.jenkins.public_ip}"
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

output "private_subnet_id" {
  value = "${aws_subnet.private_subnet.id}"
}

resource "local_file" "ansible-config" {
    content = <<DATA
---
jenkins_public_ip: ${aws_eip.jenkins.public_ip}
aws_profile: default
private_subnet_id: ${aws_subnet.private_subnet.id}
sandbox_ns_servers: ${join(",", aws_route53_zone.sandbox.name_servers)}

DATA
    filename = "${path.module}/ansible/ansible.config.yml"
}
