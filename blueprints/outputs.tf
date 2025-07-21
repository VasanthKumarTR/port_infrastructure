# Blueprints module outputs
# Exposes blueprint IDs for use by other modules

# Core Blueprint Outputs
output "microservice_blueprint_id" {
  description = "ID of the microservice blueprint"
  value       = port_blueprint.microservice.identifier
}

output "environment_blueprint_id" {
  description = "ID of the environment blueprint"
  value       = port_blueprint.environment.identifier
}

output "cluster_blueprint_id" {
  description = "ID of the cluster blueprint"
  value       = port_blueprint.cluster.identifier
}

output "repository_blueprint_id" {
  description = "ID of the repository blueprint"
  value       = port_blueprint.repository.identifier
}

# Security Blueprint Outputs
output "security_scan_blueprint_id" {
  description = "ID of the security scan blueprint"
  value       = port_blueprint.security_scan.identifier
}

output "vulnerability_blueprint_id" {
  description = "ID of the vulnerability blueprint"
  value       = port_blueprint.vulnerability.identifier
}

output "compliance_check_blueprint_id" {
  description = "ID of the compliance check blueprint"
  value       = port_blueprint.compliance_check.identifier
}

# Custom Blueprint Outputs
output "team_blueprint_id" {
  description = "ID of the team blueprint"
  value       = port_blueprint.team.identifier
}

output "api_blueprint_id" {
  description = "ID of the API blueprint"
  value       = port_blueprint.api.identifier
}

output "database_blueprint_id" {
  description = "ID of the database blueprint"
  value       = port_blueprint.database.identifier
}

output "deployment_blueprint_id" {
  description = "ID of the deployment blueprint"
  value       = port_blueprint.deployment.identifier
}

# Summary of all created blueprints
output "all_blueprint_ids" {
  description = "Map of all blueprint identifiers"
  value = {
    microservice     = port_blueprint.microservice.identifier
    environment      = port_blueprint.environment.identifier
    cluster          = port_blueprint.cluster.identifier
    repository       = port_blueprint.repository.identifier
    security_scan    = port_blueprint.security_scan.identifier
    vulnerability    = port_blueprint.vulnerability.identifier
    compliance_check = port_blueprint.compliance_check.identifier
    team             = port_blueprint.team.identifier
    api              = port_blueprint.api.identifier
    database         = port_blueprint.database.identifier
    deployment       = port_blueprint.deployment.identifier
  }
}
