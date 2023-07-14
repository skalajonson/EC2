pipeline {
    agent any
    
    stages {
        stage('Run EC2') {
            steps {
                sh '''
                cd EC2/
                terraform init
                terraform validate
                terraform apply --auto-approve
                '''
            }
        }
    }
}
