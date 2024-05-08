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
                        sh 'terraform init'
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

    // /* Cleanup stage */
    // post {
    //     always {
    //         script {
    //             withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
    //                 echo 'Waiting for 3 minutes before cleanup...'
    //                 sleep(time: 3, unit: 'MINUTES')  // Delay for 3 minutes

    //                 echo 'Cleaning up workspace'
    //                 sh 'terraform destroy -auto-approve'  // Always destroy applied resources
    //                 deleteDir()
    //             }
    //         }
    //     }
    // }
}



// pipeline {
//     agent any

//     environment {
//         TF_CLI_ARGS = '-no-color'
//     }

//     stages {
//         // /* Create a new branch and scan for changes */
//         // stage('Create Branch and Scan') {
//         //     steps {
//         //         script {
//         //             // Create a new branch named "test_branch" from main
//         //             sh 'git checkout main'
//         //             sh 'git checkout -b test_branch'
//         //             sh 'git push origin test_branch'

//         //             // Scan the Jenkins pipeline for new branches
//         //             build job: 'Jenkins-Pipeline-Scanner', parameters: [string(name: 'BRANCH_NAME', value: 'test_branch')]
//         //         }
//         //     }
//         // }

//         /* Checkout the code from the triggered branch */
//         stage('Checkout') {
//             steps {
//                 script {
//                     checkout scm
//                     echo 'Checkout stage completed sucessfully'
//                 }
//             }
//         }

//     //     stage('Lint Terraform Files') {
//     //         steps {
//     //             // Assuming your Terraform files are located in a directory called 'terraform'
//     //             dir('terraform') {
//     //                 // Run TFLint against Terraform files with formatting
//     //                 sh "tflint --format"
//     //             }
//     //         }
//     //     }
//     // }

//         // /* Validate and lint Terraform config */
//         // stage('Terraform Validate and Lint') {
//         //     steps {
//         //         script {
//         //             withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
//         //             sh 'terraform init'
//         //             echo 'Validating Terraform configuration'
//         //             sh 'terraform validate'
//         //             echo 'Validation completed sucessfully'

//         //             echo 'Linting Terraform files'
//         //              // Define the TFLint version
//         //             def tflintVersion = "v0.29.0"

//         //             // Define the download URL for TFLint
//         //             def tflintUrl = "https://github.com/terraform-linters/tflint/releases/download/${tflintVersion}/tflint_linux_amd64.zip"

//         //             // Define the directory to install TFLint
//         //             def tflintDir = "${env.WORKSPACE}/tflint"

//         //             // Create the directory if it doesn't exist
//         //             sh "mkdir -p ${tflintDir}"

//         //             // Download and extract TFLint
//         //             sh "wget ${tflintUrl} -O ${tflintDir}/tflint.zip"
//         //             sh "unzip ${tflintDir}/tflint.zip -d ${tflintDir}"

//         //             // Add TFLint to the PATH
//         //             env.PATH = "${tflintDir}:${env.PATH}"

//         //             // Verify TFLint installation
//         //             sh "tflint --version"
//         //             sh "tflint --format"
//         //             try {
//         //                 def fmtOutput = sh(script: 'terraform fmt -check', returnStdout: true).trim()
//         //                 if(fmtOutput.isEmpty()){
//         //                     echo 'Lint check completed sucessfully'
//         //                 }else{
//         //                     echo "Terraform formatting issues found:\n${fmtOutput}"
//         //                     currentBuild.result = 'FAILURE'
//         //                 } 
                        
//         //             } catch (err) {
//         //                 currentBuild.result = 'FAILURE'
//         //                 error("Terraform linting failed: ${err}")
//         //             }
//         //             }
//         //         }
//         //     }
//         // }


//         stage('Terraform Validate and Lint') {
//             steps {
//                 script {
//                     withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
//                         echo 'Validating Terraform configuration'
//                         sh 'terraform init'
//                         sh 'terraform validate'
//                         echo 'Validation completed successfully'

//                        echo 'Linting Terraform files'
//                        try {
//                             sh 'terraform fmt -check'  // Check formatting
//                             sh 'tflint'  // Run TFLint
//                         } catch (LintingException e) {
//                             echo "Terraform linting failed: ${e}"
//                             currentBuild.result = 'UNSTABLE'  // Mark build as unstable
//                         }   

//                         // echo 'Linting Terraform files'
//                         // try {
//                         //     sh "tflint --format"
//                         //     def fmtOutput = sh(script: 'terraform fmt -check', returnStdout: true).trim()
//                         //     if (fmtOutput.isEmpty()) {
//                         //         echo 'Lint check completed successfully'
//                         //     } else {
//                         //         echo "Terraform formatting issues found:\n${fmtOutput}"
//                         //         currentBuild.result = 'FAILURE'
//                         //     }
//                         // } catch (err) {
//                         //     currentBuild.result = 'FAILURE'
//                         //     error("Terraform linting failed: ${err}")
//                         // }
//                     }
//                 }
//             }
//         }

//         // Other stages...
//     }

//         /* Generate Terraform plan */
//         stage('Terraform Plan') {
//             steps {
//                 script {
//                     withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
//                         sh 'terraform init'
//                         sh 'terraform plan -out=tfplan'
//                         echo 'Terraform Plan stage completed sucessfully'
//                     }
//                 }
//             }
//         }

//         /* Apply Terraform plan (only for main branch and manual triggers) */
//         stage('Terraform Apply') {
//             when {
//                 expression { env.BRANCH_NAME == 'terra-project' }
//                 expression { currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause) != null }
//             }
//             steps {
//                 script {
//                     // Define the input step with a default value of 'No'
//                     def userInput = input(
//                         id: 'userInput',
//                         message: 'Do you want to apply changes?',
//                         parameters: [string(defaultValue: 'No', description: 'Enter "Yes" to apply changes', name: 'confirmation')],
//                         submitter: 'auto'
//                     )

//                     // Check if the user input is 'Yes'
//                     if (userInput == 'Yes') {
//                         withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
//                             sh 'terraform init'
//                             sh 'terraform apply -input=false -auto-approve tfplan'
//                             echo 'Terraform apply stage completed successfully. Resources built'
//                         }
//                     } else {
//                         echo 'Skipping Terraform apply stage as user chose not to apply changes.'
//                     }
//                 }
//             }
//         }
//     }

//     /* Cleanup stage */
//         post {
//             always {
//                 script {
//                     withCredentials([aws(credentialsId: 'AWS_CRED', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
//                         echo 'Waiting for 3 minutes before cleanup...'
//                         sleep(time: 3, unit: 'MINUTES')  // Delay for 3 minutes

//                         echo 'Cleaning up workspace'
//                         sh 'terraform destroy -auto-approve'  // Always destroy applied resources
//                         deleteDir()
//                     }
//                 }
//             }
//         }
//     }
// }    
        