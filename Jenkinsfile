pipeline {
    agent {
        docker { image 'qriousasset/jdk-mvn-py-node' }
    }

    environment { 
        JENKINS_PUB_KEY = credentials('jenkins-public-key-file')
        JENKINS_PRI_KEY = credentials('jenkins-private-key-file')
    }

    stages {
        stage('Prepare public private key pair'){
            steps {
                sh 'git clean -fdx'
                sh "mkdir ~/.ssh/ || true"
                sh "mkdir -p ~/.local/bin"
                sh "cp $JENKINS_PUB_KEY ~/.ssh/id_rsa.pub"
                sh "cp $JENKINS_PRI_KEY ~/.ssh/id_rsa && chmod 0400 ~/.ssh/id_rsa"
            }
        }

        stage('Prepare AWS Terraform and Ansible') {
            steps {
                sh 'curl -o terraform.zip https://releases.hashicorp.com/terraform/0.12.8/terraform_0.12.8_linux_amd64.zip && unzip -d ~/.local/bin/ terraform.zip'
                sh 'pip install --user ansible boto boto3'
            }
        }

        stage('Deploy with Terraform') {
            steps {
                sh 'terraform init'
                sh 'terraform workspace new mgmt-prod || true'
                sh 'terraform workspace select mgmt-prod'
//                sh 'terraform destroy --auto-approve -var-file=mgmt.tfvars'
                sh 'terraform plan -out=terraform.out -var-file=mgmt.tfvars'
                sh 'terraform apply --auto-approve -var-file=mgmt.tfvars'
                archiveArtifacts artifacts: 'ansible/*.ansible.config.yml'
            }
        }

        stage('Configure Jenkins Server'){
            steps {
	    	echo "Run ansible playbooks to configure the jenkins server"
		sh 'cd ansible; ansible-playbook jenkins-route53.yml -e @mgmt.ansible.config.yml'
                dir ('ansible') {
                    sh 'ansible-playbook jenkins-ssl.yml     -e @mgmt.ansible.config.yml'
                }
                dir ('ansible') {
                    sh 'ansible-playbook jenkins-docker.yml  -e @mgmt.ansible.config.yml'
                }
            }
        }
    }
}
