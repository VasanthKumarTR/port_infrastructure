# Port.io Infrastructure as Code - Main Configuration
# This file orchestrates the creation of the complete Port software catalog

terraform {
  required_version = ">= 1.6"
  required_providers {
    port = {
      source  = "port-labs/port-labs"
      version = "~> 2.0"
    }
  }
}

# Import utility modules
module "port_client" {
  source = "./utils"
}

# Core blueprints - foundation of the software catalog
module "core_blueprints" {
  source = "./blueprints"
  
  # Pass any shared configuration
  port_client_id     = var.port_client_id
  port_client_secret = var.port_client_secret
}

# Cloud integrations
module "aws_integration" {
  source = "./integrations/aws"
  
  depends_on = [module.core_blueprints]
  
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  aws_region           = var.aws_region
}

module "azure_integration" {
  source = "./integrations/azure"
  
  depends_on = [module.core_blueprints]
  
  azure_client_id     = var.azure_client_id
  azure_client_secret = var.azure_client_secret
  azure_tenant_id     = var.azure_tenant_id
}

# Development tool integrations
module "github_integration" {
  source = "./integrations/github"
  
  depends_on = [module.core_blueprints]
  
  github_app_id          = var.github_app_id
  github_private_key     = var.github_private_key
  github_installation_id = var.github_installation_id
}

module "azure_devops_integration" {
  source = "./integrations/azure_devops"
  
  depends_on = [module.core_blueprints]
  
  azdo_organization_url = var.azdo_organization_url
  azdo_personal_token   = var.azdo_personal_token
}

# Security integrations
module "snyk_integration" {
  source = "./integrations/snyk"
  
  depends_on = [module.core_blueprints]
  
  snyk_token        = var.snyk_token
  snyk_organization = var.snyk_organization
}

# DORA metrics configuration
module "dora_metrics" {
  source = "./integrations/dora"
  
  depends_on = [module.core_blueprints]
}

# Self-service actions and workflows
module "service_actions" {
  source = "./actions"
  
  depends_on = [module.core_blueprints]
  
  github_actions_webhook_url = var.github_actions_webhook_url
}

# Drift detection and monitoring
module "drift_detection" {
  source = "./utils/drift_detection"
  
  depends_on = [
    module.core_blueprints,
    module.aws_integration,
    module.azure_integration,
    module.github_integration
  ]
}
