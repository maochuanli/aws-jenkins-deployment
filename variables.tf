variable "env" {
  description = "the current execution environment"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "key_file_path" {
  description = "Local file path for the private key"
  default = "~/.ssh/id_rsa"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-2"
}


# Debian-9 Stretch Market place AMI  
variable "aws_amis" {
  default = {
    ap-southeast-2 = "ami-0019173738c29be04"
  }
}

variable "vpc_prefix" {
  description = "The name for all resources"
  default = "jenkins-vpc"
}

variable "vpc_cidr" {
  description = "The cidr for VPC"
  default = "172.25.212.0/24"
}

variable "public_subnet_cidr" {
  description = "The public subnet cidr in VPC"
}

variable "private_subnet_cidr" {
  description = "The private subnet cidr in VPC"
}

