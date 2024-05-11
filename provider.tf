terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
  }

  backend "s3" {
    bucket = "terraform-s3bucket-for-practice"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
