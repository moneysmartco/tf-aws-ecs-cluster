terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    spotinst = {
      source  = "spotinst/spotinst"
      version = "~> 1.68.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
  required_version = ">= 0.13"
}
