terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.97"
    }
    aap = {
      source = "ansible/aap"
    }
  }
  required_version = "~> 1.2"
}
