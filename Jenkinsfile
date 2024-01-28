pipeline {
    agent any

    environment {
        TF_CLI_ARGS = 'no-color'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage('Terraform Validate and Lint') {
        steps {
            script {
                withCredentials([aws(credentialsId: 'AWS-Authentication', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                //sh 'terraform init'
                echo 'Validating Terraform configuration'
                sh 'terraform validate'
                echo 'Validation completed sucessfully'

                echo 'Linting Terraform files'
                try {
                    def fmtOutput = sh(script: 'terraform fmt -check', returnStdout: true).trim()
                    if(fmtOutput.isEmpty()){
                        echo 'Lint check completed sucessfully'
                    }else{
                        echo "Terraform formatting issues found:\n${fmtOutput}"
                        currentBuild.result = 'FAILURE'
                    }

                } catch (err) {
                    currentBuild.result = 'FAILURE'
                    error("Terraform linting failed: ${err}")
                }
                }
            }
        }
    }

        stage('Terraform Plan') {
            steps {
                script {
                    echo 'Starting Terraform Plan'
                    withCredentials([aws(credentialsId: 'AWS-Authentication', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        // sh 'terraform init'
                        sh 'terraform plan -out=tfplan'
                    }
                     echo 'Terraform Plan stage completed sucessfully'
                }
            }
        }

        // stage('Terraform Apply') {
        //     when {
        //         expression { env.BRANCH_NAME == 'main' }
        //         expression { currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause) != null }
        //     }
        //     steps {
        //         script {
        //             echo 'Starting Terraform Apply'
        // //             // Ask for manual confirmation before applying changes
        //             input message: 'Do you want to apply changes?', ok: 'Yes'
        //             withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        //                 sh 'terraform init'
        //                 sh 'terraform apply tfplan'

        //             }
        //             echo 'Terraform Apply completed'
        //         }
        //     }
        // }

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
                        withCredentials([aws(credentialsId: 'AWS-Authentication', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            //sh 'terraform init'
                            sh 'terraform apply -input=false -auto-approve tfplan'
                            echo 'Terraform apply stage completed successfully. Resources built'
                        }
                    } else {
                        echo 'Skipping Terraform apply stage as user chose not to apply changes.'
                    }
                }
            }
        }

//         stage('Cleanup') {
//             steps {
//                 script {
//                     echo 'Starting Cleanup'
//                     // Add cleanup tasks here
//                     echo 'Cleanup completed'
//                 }
//             }
//         }


//         stage('Destroy Infrastructure') {
//             steps {
//                 script {
//                     echo 'Starting Infrastructure Destruction'
//                     // Run Terraform destroy command
//                     sh 'terraform destroy -auto-approve'
//                     echo 'Infrastructure Destruction completed'
//                 }
//             }
// }

    }
}
