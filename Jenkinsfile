pipeline {
    agent {
        docker { image 'qriousasset/jdk-mvn-py-node' }
    }

    environment { 
        JENKINS_PUB_KEY = credentials('jenkins-public-key-file')
        JENKINS_PRI_KEY = credentials('jenkins-private-key-file')
        HOME = "/home/developer"
    }

    stages {
        stage('Prepare public private key pair'){
            steps {
                sh 'git clean -fdx'
                sh "mkdir ~/.ssh/ || true"
                sh "mkdir -p ~/.local/bin"
                sh "cp $JENKINS_PUB_KEY ~/.ssh/id_rsa.pub"
                sh "cp $JENKINS_PRI_KEY ~/.ssh/id_rsa"
                sh "ls -l ~/.ssh/"
                sh "cat ~/.ssh/id_rsa"
                archiveArtifacts artifacts: "Jenkinsfile", fingerprint: true
            }
        }

        stage('Prepare AWS Terraform and Ansible') {
            steps {
                sh 'curl -o terraform.zip https://releases.hashicorp.com/terraform/0.12.8/terraform_0.12.8_linux_amd64.zip && unzip -d ~/.local/bin/ terraform.zip'
                sh 'cp -r aws ~/.aws'
                sh 'pip install --user ansible boto'
//                sh 'pip install --user awscli'
            }
        }

        stage('Deploy with Terraform') {
            steps {
                sh 'terraform init'
                sh 'terraform workspace new mgmt-prod || true'
                sh 'terraform workspace select mgmt-prod'
                sh 'terraform plan -out=terraform.out -var-file=mgmt.tfvars'
                sh 'terraform apply --auto-approve -var-file=mgmt.tfvars'
                archiveArtifacts artifacts: 'ansible/*.ansible.config.yml'
            }
        }

        stage('Configure Jenkins Server'){
            steps {
                sh 'ls -l ~/'
		sh 'cp -r aws ~/.aws'
		sh 'ls -l ~/'
		dir ('ansible') {
                  sh 'ls -lh'
                  sh 'which ansible-playbook'
                  sh 'ansible-playbook jenkins-route53.yml -e @mgmt.ansible.config.yml -vvvv'
                }
		
            }
        }
    }
}
