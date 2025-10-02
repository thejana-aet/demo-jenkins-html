terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Managed_by           = "Terraform"
      Owner                = "Thejana"
      Initial_Created_Date = "27/Sep/2025"
    }
  }
}
