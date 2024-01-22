pipeline {
    agent any

    environment {
        TF_CLI_ARGS = '-no-color'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage('Terraform Lint') {
            steps {
                script {
                    echo 'Starting Terraform Lint'
                    sh 'tflint'
                    echo 'Terraform Lint completed'
                }
            }
        }

         stage('Terraform Validate') {
            steps {
                script {
                    echo 'Starting Terraform Validate'
                    sh 'terraform init -backend=false'  // Initialize without backend configuration
                    sh 'terraform validate'
                    echo 'Terraform Validate completed'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    echo 'Starting Terraform Plan'
                    withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh 'terraform init'
                        sh 'terraform plan -out=tfplan'
                    }
                     echo 'Terraform Plan completed'
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { env.BRANCH_NAME == 'main' }
                expression { currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause) != null }
            }
            steps {
                script {
                    echo 'Starting Terraform Apply'
        //             // Ask for manual confirmation before applying changes
                    input message: 'Do you want to apply changes?', ok: 'Yes'
                    withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh 'terraform init'
                        sh 'terraform apply tfplan'

                    }
                    echo 'Terraform Apply completed'
                }
            }
        }
    }
}
