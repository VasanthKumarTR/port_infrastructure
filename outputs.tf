# Port.io Infrastructure Outputs
# These outputs provide information about the created resources

# Note: Outputs are temporarily disabled while restructuring the configuration
# Individual resources will output their values directly when needed

output "infrastructure_status" {
  description = "Status of the Port.io infrastructure deployment"
  value = {
    environment = var.environment
    timestamp   = timestamp()
    status      = "deployed"
  }
}
