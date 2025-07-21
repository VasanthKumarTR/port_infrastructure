# GitHub integration module variables

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

variable "github_webhook_url" {
  description = "Webhook URL for real-time GitHub updates"
  type        = string
  sensitive   = true
}

variable "sync_schedule" {
  description = "Cron schedule for periodic sync"
  type        = string
  default     = "0 2 * * *" # Daily at 2 AM
}

variable "enable_audit_logging" {
  description = "Enable audit logging for GitHub resources"
  type        = bool
  default     = true
}

variable "team_email" {
  description = "Team email for notifications"
  type        = string
}
