# README #

This project is to automatically set up jenkins server

### Requirements ###

* terraform -version | Terraform v0.12.6
* ansible --version  | ansible 2.7.9


### How do I execute ###

* create 2 AWS profiles: sandbox and mgmt
* create VPC with project: git@bitbucket.org:qriousnz/ansible-pb-aviatrix-peering.git
* > terraform init -backend-config=prod.backend
* > terraform plan -var-file=prod.tfvars
* > terraform plan -var-file=prod.tfvars
* > cd ansible/
* > ansible-playbook  jenkins-ssl.yml -e @prod.ansible.config.yml -vvv
* > ansible-playbook  jenkins-docker.yml -e @prod.ansible.config.yml -vvv
