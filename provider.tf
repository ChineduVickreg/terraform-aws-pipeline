terraform {
  required_version = "~> 1.8.2" 
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.48.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.6"
    }
  }

  backend "s3" {
    bucket = "terraform-s3bucket-for-practice"
    key    = "terraform.tfstate"
    region = "us-east-1 "
  }
}
