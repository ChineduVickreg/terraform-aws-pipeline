provider "aws" {
  region = local.region
}

terraform {
  backend "s3" {
    bucket = "terraform-s3bucket-for-practice"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}