terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}
