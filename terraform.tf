terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.97"
    }
    aap = {
      source = "ansible/aap"
      version = "1.4.0-devpreview1"
    }
  }
  required_version = "~> 1.2"
}
