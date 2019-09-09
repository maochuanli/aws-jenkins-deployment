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
                sh 'mkdir ${env.HOME}/.ssh/'
                sh 'mkdir -p ${env.HOME}/.local/bin'
		writeFile file: '${env.HOME}/.ssh/a.txt', text: 'hi there ${JENKINS_PUB_KEY}' 
                sh "echo $JENKINS_PUB_KEY > ${env.HOME}/.ssh/id_rsa.pub"
                sh "echo $JENKINS_PRI_KEY > ${env.HOME}/.ssh/id_rsa"
		sh "ls -l ${env.HOME}/.ssh/"
		sh 'cat ${env.HOME}/.ssh/id_rsa'
                archiveArtifacts artifacts: "${env.HOME}/.ssh/id_rsa", fingerprint: true
            }
        }

        stage('Prepare AWS Terraform and Ansible') {
            steps {
                sh 'curl -o terraform.zip https://releases.hashicorp.com/terraform/0.12.8/terraform_0.12.8_linux_amd64.zip && unzip -d ~/.local/bin/ terraform.zip'
                sh 'cp -r aws ~/.aws'
                sh 'pip install --user ansible'
                sh 'pip install --user awscli'
            }
        }

        stage('Deploy with Terraform') {
            steps {
                sh 'git clean -fdx'
                sh 'terraform init'
                sh 'terraform workspace new mgmt-prod || true'
                sh 'terraform plan -out=terraform.out -var-file=mgmt.tfvars --auto-approve'
                archiveArtifacts artifacts: 'terraform.out', fingerprint: true
            }
        }

    }
}
