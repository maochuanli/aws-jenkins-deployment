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
  default = "mao_home_id_rsa"
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
  default = "172.25.212.224/28"
}

variable "private_subnet_cidr" {
  description = "The private subnet cidr in VPC"
  default = "172.25.212.192/27"
}

#http://www.davidc.net/sites/default/subnets/subnets.html?network=172.25.212.0&mask=24&division=3.1
#172.25.212.0/24	255.255.255.0	172.25.212.0 - 172.25.212.255	172.25.212.1 - 172.25.212.254	254 
#Subnet address	Netmask		Range of addresses	Useable IPs	Hosts	Divide	Join
#172.25.212.0/25	255.255.255.128	172.25.212.0 - 172.25.212.127	172.25.212.1 - 172.25.212.126	126	Divide		
#172.25.212.128/26		255.255.255.192			172.25.212.128 - 172.25.212.191	172.25.212.129 - 172.25.212.190 62 Divide  
#172.25.212.192/27		255.255.255.224			172.25.212.192 - 172.25.212.223	172.25.212.193 - 172.25.212.222	30 Divide   
#172.25.212.224/28		255.255.255.240			172.25.212.224 - 172.25.212.239	172.25.212.225 - 172.25.212.238	14 Divide    
#172.25.212.240/28		255.255.255.240			172.25.212.240 - 172.25.212.255	172.25.212.241 - 172.25.212.254	14 Divide    