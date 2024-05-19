pipeline {
    agent any

    environment {
        TF_CLI_ARGS = '-no-color'
    }

    stages {
        /* Checkout the code from the triggered branch */
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                    echo 'Checkout stage completed successfully'
                }
            }
        }

        stage('Terraform Validate and Lint') {
            steps {
                script {
                    withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        echo 'Validating Terraform configuration'
                        sh 'terraform init'
                        sh 'terraform validate'
                        echo 'Validation completed successfully'

                        echo 'Linting Terraform files'
                        try {
                            sh 'terraform fmt -check'  // Check formatting
                            sh 'tflint'  // Run TFLint
                        } catch (Exception e) {
                            echo "An error occurred during linting: ${e}"
                            currentBuild.result = 'UNSTABLE'  // Mark build as unstable
}
                    }
                }
            }
        }

        // Other stages...

        /* Generate Terraform plan */
        stage('Terraform Plan') {
            steps {
                script {
                    withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh 'terraform init -upgrade'
                        sh 'terraform plan -out=tfplan'
                        echo 'Terraform Plan stage completed successfully'
                    }
                }
            }
        }

        /* Apply Terraform plan (only for main branch and manual triggers) */
        stage('Terraform Apply') {
            when {
                expression { env.BRANCH_NAME == 'terra-project' }
                expression { currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause) != null }
            }
            steps {
                script {
                    // Define the input step with a default value of 'No'
                    def userInput = input(
                        id: 'userInput',
                        message: 'Do you want to apply changes?',
                        parameters: [string(defaultValue: 'No', description: 'Enter "Yes" to apply changes', name: 'confirmation')],
                        submitter: 'auto'
                    )

                    // Check if the user input is 'Yes'
                    if (userInput == 'Yes') {
                        withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh 'terraform init'
                            sh 'terraform apply -input=false -auto-approve tfplan'
                            echo 'Terraform apply stage completed successfully. Resources built'
                        }
                    } else {
                        echo 'Skipping Terraform apply stage as user chose not to apply changes.'
                    }
                }
            }
        }
    }

    /* Cleanup stage */
    post {
        always {
            script {
                withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    echo 'Waiting for 3 minutes before cleanup...'
                    sleep(time: 3, unit: 'MINUTES')  // Delay for 3 minutes

                    echo 'Cleaning up workspace'
                    sh 'terraform destroy -auto-approve'  // Always destroy applied resources
                    deleteDir()
                }
            }
        }
    }
}
