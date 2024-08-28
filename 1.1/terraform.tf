terraform {
  required_version = "~> 1.9.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6.2"
    }
  }
}