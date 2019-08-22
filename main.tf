# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "public_subnet" {
  #name = "${var.vpc_prefix}-public-subnet"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.public_subnet_cidr}"
  map_public_ip_on_launch = true
}

# Create a subnet to launch our slaves into
resource "aws_subnet" "private_subnet" {
  #name = "${var.vpc_prefix}-private-subnet"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.private_subnet_cidr}"
  map_public_ip_on_launch = false
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "webserver-security-group"
  description = "Used in the terraform"
  vpc_id      = "${var.vpc_id}"

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
    cidr_blocks = ["0.0.0.0/0"]
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


resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ec2-ser"
    host = "${self.public_ip}"
    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.public_subnet.id}"

  tags = {
    Name = "HelloWorld"
  }

  user_data = <<DATA
#!/bin/bash
yum update -y
yum -y install nginx docker
systemctl enable nginx
systemctl enable docker
systemctl start nginx
systemctl start docker
usermod -aG docker ec2-user

DATA

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "whoami",
      "pwd"
      
      
    ]
  }
}

output "address" {
  value = "${aws_instance.web.public_ip}"
}
