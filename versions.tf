
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    null = {
      source = "hashicorp/null"
    }
    spotinst = {
      source = "spotinst/spotinst"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}
