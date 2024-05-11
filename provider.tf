terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.6"
    }
  }

  backend "s3" {
    bucket = "terraform-s3bucket-for-practice"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
