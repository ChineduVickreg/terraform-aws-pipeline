# terraform-aws-pipeline
Implementing CICD Pipeline For Terraform Using Jenkins

INTRODUCTION
Continuous Integration and Continuous Deployment (CI/CD) has emerged as indispensable practices, fostering automation in software development lifecycle. In this project, we shall explore the powerful combination of Terraform, a widely used Infrastructure as Code (IaC) for provisioning servers and other infrastructures on cloud providers and Jenkins, a widely used automation server, to enhance and streamline infrastructure deployment workflow.

Project Overview:
In this project, I will delve into the intricacies of building a robust CI/CD pipeline specially tailored for Terraform projects. By automating the building, testing, and deployment of infrastructure changes, these pipelines enhance speed, reliability, and consistency across environments. The use of Infrastructure as Code (IaC) with Terraform ensures reproductivity and scalability while Jenkins facilitates collaborative development, visibility, and continuous integration and deployment.
This approach not only reduces time-to market but also promotes resource efficiency, cost-optimization and compliance with security standards.
Overall, the CICD pipeline with Terraform and Jenkins empower organizations to adapt quickly to changing business requirements, fostering a culture of information and continuous improvement in the dynamic landscape of modern software development and operations.


Setting Up the Environment
Tools needs for the project:
Terraform 
Jenkins
AWS cloud provider
Docker

Dockerfile For Jenkins
I used a Dockerfile to configure a Jenkin server that will enable the running of the pipeline.
I created a directory called terraform-with-cicd.
I created a Dockerfile extension file called Dockerfile.

Then I added the contents below to the file extension:
“ # Use the official Jenkins base image
 FROM jenkins/jenkins:lts

 # Switch to the root user to install additional packages
 USER root

 # Install necessary tools and dependencies (e.g., Git, unzip, wget, software-properties-common)
 RUN apt-get update && apt-get install -y \
     git \
     unzip \
     wget \
     software-properties-common \
     && rm -rf /var/lib/apt/lists/*

 # Install Terraform
 RUN apt-get update && apt-get install -y gnupg software-properties-common wget \
     && wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg \
     && gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint \
     && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
     && apt-get update && apt-get install -y terraform \
     && rm -rf /var/lib/apt/lists/*

 # Set the working directory
 WORKDIR /app

 # Print Terraform version to verify installation
 RUN terraform --version

 # Switch back to the Jenkins user
 USER jenkins ”

Then i ran the following commands to build the image and run the container:
Building the image: 
 docker build -t jenkins-server . 

Run the container:
docker run -d -p 8080:8080 --name jenkins-server jenkins-server 

Checking if the container is running:
docker ps
I access the Jenkins server from the web server using:
Localhost:8080
I access the Jenkins server directly from the container using:
docker exec -it  bf7237ac9d18  /bin/bash to get into the /app WORKDIR to retrieve the initial Jenkins admin password using this command “jenkins@bf7237ac9d18:/app$ cat /var/jenkins_home/secrets/initialAdminPassword”
 I paste the password I got into the Jenkin GUI and proceed to installing Plugin.
I clicked on the “install suggested Jenkins plugin.
I created the first admin user and accessed Jenkins.

Setting Up Jenkins For Terraform CICD.
I set up a github repository with Terraform code by coding this repo “https://github.com/hineduVickreg/terraform-aws-pipeline.git”.
Then I tested the provider.tf file to configure the s3 bucket for backend configuration to store terraform files remotely. This I did by creating an s3 bucket in Aws console management and updating the name in the provider.tf.
I pushed the latest changes to github.
Then I ran terraform init, plan, and apply to confirm that everything is working fine. 

Connected the Github Repository to Jenkins.
I installed github repository plugins to the Jenkins server by opening it using “http://localhost:8080/” 
I installed Terraform Plugins in the Jenkins server to enable seamless integration of Terraform in the Jenkins server.
Also I installed AWS Credential Plugins in the Jenkins server, this will help to secure the AWS credentials and allow Jenkins and Terraform to communicate with provisioning the infrastructures when changes are made.




Configured The GitHub Credentials in Jenkins and Aws credentials.
I configured the github credentials by going to the repository I am working on. I went to settings -> developer settings -> Tokens -> Generate new token(classic) -> Generate tokens.
Then I copied the token generated to the Jenkins server.
On the Jenkins server, I went to manage Jenkins -> Credentials -> global -> Username with password -> Create
Also I added my AWS access credentials to the jenkins server by taking the same route, I went to manage Jenkins -> Credentials -> global -> chose Aws Credentials -> typed AWS_CRED, and put in the Access Key and Aws secret key and click create.

Set-up a Jenkins Multibranch Pipeline.
I clicked on to create the “New Item”.
Select the “multiple branch pipeline”.
I gave the pipeline a choiced name.
I gave it a description. 
Saved.
I selected the source code versioning tool (Github) and the Jenkinsfile.
I selected the credentials that will be used to connect to Github from Jenkins.
I added the Github repository url.
And left every other thing as default and saved it.
The main branch of the repository and Jenkinsfile is scanned.
And the pipeline runs.
I clicked on the output on the Jenkins server console to view the build activity.

Documenting the Pipeline.
I created a new branch from main and scanned it to make sure it is discovered.
I updated the ‘sh terraform aply -out=tfplan’ command to ‘sh terraform apply tfplan’
I added logging to track the progress of the pipeline between both the ‘terraform plan’ and ‘apply’ using ‘echo command’ to print messages before and after the execution of both commands so that everyone will understand what is going on between the stages in the console output.
I added the ‘terraform validate’ as a new stage to validate pipeline configuration.
I also added the ‘Lint code’ stage before the terraform plan so as to validate the syntax, consistency and correctness of terraform configuration files in the directory if it runs.
I added a ‘Cleanup’ stage.
And lastly an error handling stage 
Errors Encountered and Error Handling.


