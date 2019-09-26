# README #

This project is to automatically set up jenkins server

### Requirements ###

* terraform -version | Terraform v0.12.6
* ansible --version  | ansible 2.7.9


### How do I execute ###

* > terraform init
* > terraform workspace select mgmt-prod
* > terraform plan -out=terraform.out -var-file=mgmt.tfvars -var=public_key_path=~/.ssh/jenkins_id_rsa.pub
* > terraform apply terraform.out
* > 
* > cd ansible
* > 
* > ansible-playbook      	      	      	  jenkins-route53.yml -e @mgmt.ansible.config.yml
* > ansible-playbook --key-file ~/jenkins_id_rsa  jenkins-ssl.yml -e @mgmt.ansible.config.yml
* > ansible-playbook --key-file ~/jenkins_id_rsa  jenkins-docker.yml -e @mgmt.ansible.config.yml
