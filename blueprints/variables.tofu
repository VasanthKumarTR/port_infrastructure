# Blueprint module variables
# Variables used across all blueprint definitions

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

variable "enable_audit_logging" {
  description = "Enable audit logging for all blueprints"
  type        = bool
  default     = true
}
