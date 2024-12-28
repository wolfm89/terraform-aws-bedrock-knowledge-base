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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.3"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Terraform = "true"
      Creator   = var.creator
    }
  }
}

provider "opensearch" {
  aws_region  = "eu-central-1"
  url         = aws_opensearchserverless_collection.knowledge_base.collection_endpoint
  healthcheck = false
}
