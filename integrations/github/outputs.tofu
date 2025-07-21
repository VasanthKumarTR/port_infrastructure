# GitHub integration outputs

output "integration_id" {
  description = "ID of the GitHub integration"
  value       = port_integration.github.identifier
  sensitive   = true
}

output "webhook_action_id" {
  description = "ID of the GitHub webhook action"
  value       = port_action.github_webhook.identifier
}

output "blueprint_ids" {
  description = "IDs of blueprints created for GitHub integration"
  value = {
    pull_request  = port_blueprint.pull_request.identifier
    workflow      = port_blueprint.workflow.identifier
    workflow_run  = port_blueprint.workflow_run.identifier
  }
}
