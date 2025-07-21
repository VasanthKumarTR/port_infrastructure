# Port.io Provider Configuration
# Configures the Port provider with authentication and base URL

terraform {
  required_version = ">= 1.6"
  required_providers {
    port = {
      source  = "port-labs/port-labs"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Port provider configuration
provider "port" {
  client_id     = var.port_client_id
  client_secret = var.port_client_secret
  base_url      = var.port_base_url
}

# AWS provider configuration for cloud integrations
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  
  default_tags {
    tags = {
      ManagedBy    = "OpenTofu"
      Environment  = var.environment
      Project      = "port-infrastructure"
      Owner        = var.team_email
    }
  }
}

# Azure provider configuration for cloud integrations
provider "azurerm" {
  features {}
  
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}
