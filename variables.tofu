# Variable definitions for Port.io infrastructure configuration
# Mark sensitive variables appropriately for security

# Port Configuration
variable "port_client_id" {
  description = "Port.io client ID for API authentication"
  type        = string
  sensitive   = true
}

variable "port_client_secret" {
  description = "Port.io client secret for API authentication"
  type        = string
  sensitive   = true
}

variable "port_base_url" {
  description = "Port.io base URL"
  type        = string
  default     = "https://api.getport.io"
}

# Environment Configuration
variable "environment" {
  description = "Environment name (prod, staging, dev)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["prod", "staging", "dev"], var.environment)
    error_message = "Environment must be one of: prod, staging, dev."
  }
}

variable "team_email" {
  description = "Team email for resource ownership"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.team_email))
    error_message = "Team email must be a valid email address."
  }
}

# AWS Configuration
variable "aws_access_key_id" {
  description = "AWS access key ID for cloud integration"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key for cloud integration"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-west-2"
}

# Azure Configuration
variable "azure_client_id" {
  description = "Azure service principal client ID"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure service principal client secret"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

# GitHub Configuration
variable "github_app_id" {
  description = "GitHub App ID for integration"
  type        = string
  sensitive   = true
}

variable "github_private_key" {
  description = "GitHub App private key"
  type        = string
  sensitive   = true
}

variable "github_installation_id" {
  description = "GitHub App installation ID"
  type        = string
  sensitive   = true
}

variable "github_actions_webhook_url" {
  description = "GitHub Actions webhook URL for self-service actions"
  type        = string
  sensitive   = true
}

# Azure DevOps Configuration
variable "azdo_organization_url" {
  description = "Azure DevOps organization URL"
  type        = string
}

variable "azdo_personal_token" {
  description = "Azure DevOps personal access token"
  type        = string
  sensitive   = true
}

# Snyk Configuration
variable "snyk_token" {
  description = "Snyk API token for security scanning"
  type        = string
  sensitive   = true
}

variable "snyk_organization" {
  description = "Snyk organization ID"
  type        = string
}

# Optional Configuration
variable "enable_audit_logging" {
  description = "Enable audit logging for all Port resources"
  type        = bool
  default     = true
}

variable "drift_detection_schedule" {
  description = "Cron schedule for drift detection (weekly by default)"
  type        = string
  default     = "0 2 * * 1" # Every Monday at 2 AM
}

variable "sync_schedule" {
  description = "Cron schedule for daily syncs"
  type        = string
  default     = "0 1 * * *" # Every day at 1 AM
}
