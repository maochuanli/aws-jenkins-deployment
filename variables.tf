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

variable "aws_profile" {
  default = "sandbox"
}

# Amazon Linux 2 comes with five years support.
# Debian-9 Stretch Market place AMI  
variable "aws_amis" {
  default = {
    #ap-southeast-2 = "ami-0dc96254d5535925f"
    ap-southeast-2 = "ami-00a5fc80ec944398f"
  }
}

variable "vpc_prefix" {
  description = "To name all resource with this prefix"
  default = "sandbox-jenkins"
}

variable "public_subnet_cidr" {
  description = "The public subnet cidr in VPC"
}

variable "private_subnet_cidr" {
  description = "The private subnet cidr in VPC"
}
