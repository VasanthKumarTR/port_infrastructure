# Output values for Port.io infrastructure
# These outputs can be used by other systems or for reference

# Core Blueprint Outputs
output "microservice_blueprint_id" {
  description = "ID of the microservice blueprint"
  value       = module.core_blueprints.microservice_blueprint_id
}

output "environment_blueprint_id" {
  description = "ID of the environment blueprint"
  value       = module.core_blueprints.environment_blueprint_id
}

output "cluster_blueprint_id" {
  description = "ID of the cluster blueprint"
  value       = module.core_blueprints.cluster_blueprint_id
}

output "repository_blueprint_id" {
  description = "ID of the repository blueprint"
  value       = module.core_blueprints.repository_blueprint_id
}

# Integration Outputs
output "github_integration_id" {
  description = "ID of the GitHub integration"
  value       = module.github_integration.integration_id
  sensitive   = true
}

output "aws_integration_id" {
  description = "ID of the AWS integration"
  value       = module.aws_integration.integration_id
  sensitive   = true
}

output "azure_integration_id" {
  description = "ID of the Azure integration"
  value       = module.azure_integration.integration_id
  sensitive   = true
}

# DORA Metrics Outputs
output "dora_blueprint_id" {
  description = "ID of the DORA metrics blueprint"
  value       = module.dora_metrics.dora_blueprint_id
}

# Self-Service Actions Outputs
output "provision_microservice_action_id" {
  description = "ID of the provision microservice action"
  value       = module.service_actions.provision_microservice_action_id
}

# Security and Monitoring Outputs
output "audit_logging_enabled" {
  description = "Whether audit logging is enabled"
  value       = var.enable_audit_logging
}

output "drift_detection_schedule" {
  description = "Cron schedule for drift detection"
  value       = var.drift_detection_schedule
}

# Summary Information
output "port_catalog_summary" {
  description = "Summary of the Port catalog configuration"
  value = {
    blueprints_created = [
      module.core_blueprints.microservice_blueprint_id,
      module.core_blueprints.environment_blueprint_id,
      module.core_blueprints.cluster_blueprint_id,
      module.core_blueprints.repository_blueprint_id,
      module.dora_metrics.dora_blueprint_id
    ]
    integrations_configured = [
      "github",
      "aws",
      "azure",
      "azure_devops",
      "snyk"
    ]
    actions_available = [
      "provision_microservice"
    ]
    security_features = {
      audit_logging    = var.enable_audit_logging
      vault_integration = true
      rbac_enabled     = true
    }
  }
}
