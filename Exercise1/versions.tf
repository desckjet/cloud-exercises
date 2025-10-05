terraform {
  required_version = ">= 1.13.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.15"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.47"
    }
  }

  backend "s3" {
    bucket       = "cloud-exercises-terraform-state"
    key          = "exercise1/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
