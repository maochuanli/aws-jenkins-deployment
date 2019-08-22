variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
  default = "~/.ssh/id_rsa.pub"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "jenkins"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  default = "sandbox"
}

# Amazon Linux 2 comes with five years support. 
variable "aws_amis" {
  default = {
    ap-southeast-2 = "ami-0dc96254d5535925f"
  }
}

variable "vpc_prefix" {
  description = "To name all resource with this prefix"
  default = "sandbox-jenkins-vpc"
}

variable "vpc_id" {
  description = "The existing vpc id, created by ansible playbook"
  default = "vpc-0e5a78df0da71cb8f"
}

variable "public_subnet_cidr" {
  description = "The public subnet cidr in VPC"
  default = "172.25.212.0/25"
}

variable "private_subnet_cidr" {
  description = "The private subnet cidr in VPC"
  default = "172.25.212.128/25"
}
