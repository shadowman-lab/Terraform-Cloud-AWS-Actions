terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.97"
    }
  }
  required_version = "~> 1.14.0-beta3"
}
