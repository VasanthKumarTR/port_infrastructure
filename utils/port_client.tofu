# Port Client Utility Module
# Provides reusable functions and configurations for Port.io operations

# Port Client Configuration
locals {
  # Standard retry configuration
  retry_config = {
    max_retries     = 3
    retry_delay_ms  = 1000
    backoff_factor  = 2
  }
  
  # Common headers for Port API calls
  standard_headers = {
    "Content-Type"  = "application/json"
    "User-Agent"    = "OpenTofu-Port-Provider/1.0"
  }
  
  # Standard tags for all Port resources
  standard_properties = {
    managed_by       = "OpenTofu"
    created_at      = timestamp()
    environment     = var.environment
    infrastructure  = "port-iac"
  }
}

# Data source for Port organization info
data "port_organization" "current" {
  # This provides access to the current Port organization details
}

# Standard validation rules
locals {
  validation_rules = {
    # Email validation regex
    email_regex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    
    # Service name validation (kebab-case)
    service_name_regex = "^[a-z][a-z0-9-]*[a-z0-9]$"
    
    # Environment validation
    valid_environments = ["development", "staging", "production"]
    
    # Severity levels
    severity_levels = ["critical", "high", "medium", "low"]
    
    # DORA performance categories
    dora_categories = {
      deployment_frequency = ["on_demand", "daily", "weekly", "monthly", "less_than_monthly"]
      lead_time           = ["less_than_one_hour", "one_day", "one_week", "one_month", "more_than_one_month"]
      change_failure_rate = ["0_to_15_percent", "16_to_30_percent", "31_to_45_percent", "46_to_60_percent", "over_60_percent"]
      mttr               = ["less_than_one_hour", "one_day", "one_week", "one_month", "more_than_one_month"]
    }
  }
}

# Error handling configuration
locals {
  error_handling = {
    # Common error codes and their meanings
    error_codes = {
      "400" = "Bad Request - Invalid input parameters"
      "401" = "Unauthorized - Invalid credentials"
      "403" = "Forbidden - Insufficient permissions"
      "404" = "Not Found - Resource does not exist"
      "409" = "Conflict - Resource already exists"
      "422" = "Unprocessable Entity - Validation failed"
      "429" = "Too Many Requests - Rate limit exceeded"
      "500" = "Internal Server Error - Port service error"
    }
    
    # Retry conditions
    retryable_errors = ["429", "500", "502", "503", "504"]
  }
}

# Common webhook configurations
locals {
  webhook_config = {
    # Standard webhook timeout
    timeout_seconds = 30
    
    # Standard headers for outgoing webhooks
    webhook_headers = {
      "Content-Type"     = "application/json"
      "X-Port-Source"    = "port-integration"
      "X-Port-Timestamp" = "{{ .timestamp }}"
    }
    
    # Webhook authentication method
    auth_method = "bearer_token"
  }
}

# Integration sync schedules
locals {
  sync_schedules = {
    # Real-time sync for critical resources
    realtime = "*/5 * * * *"  # Every 5 minutes
    
    # Hourly sync for frequently changing resources
    hourly = "0 * * * *"      # Every hour
    
    # Daily sync for most resources
    daily = "0 2 * * *"       # Daily at 2 AM
    
    # Weekly sync for stable resources
    weekly = "0 2 * * 1"      # Weekly on Monday at 2 AM
    
    # Monthly sync for archival data
    monthly = "0 2 1 * *"     # Monthly on the 1st at 2 AM
  }
}

# Resource naming conventions
locals {
  naming_conventions = {
    # Blueprint naming pattern
    blueprint_pattern = "^[a-z][a-z0-9_]*[a-z0-9]$"
    
    # Entity identifier pattern
    entity_pattern = "^[a-z0-9][a-z0-9-_]*[a-z0-9]$"
    
    # Integration identifier pattern
    integration_pattern = "^[a-z][a-z0-9-]*[a-z0-9]$"
    
    # Action identifier pattern
    action_pattern = "^[a-z][a-z0-9_]*[a-z0-9]$"
  }
}

# Security configurations
locals {
  security_config = {
    # Sensitive properties that should be encrypted
    sensitive_properties = [
      "password",
      "token", 
      "key",
      "secret",
      "credential",
      "connection_string"
    ]
    
    # Properties that should be marked as secret
    secret_properties = [
      "api_key",
      "private_key",
      "client_secret",
      "access_token",
      "refresh_token"
    ]
    
    # Default encryption settings
    encryption_defaults = {
      algorithm = "AES-256-GCM"
      key_rotation_days = 90
    }
  }
}

# Monitoring and alerting configurations
locals {
  monitoring_config = {
    # Health check intervals
    health_check_intervals = {
      critical = "30s"
      high     = "1m"
      medium   = "5m"
      low      = "15m"
    }
    
    # Alert thresholds
    alert_thresholds = {
      error_rate = {
        warning  = 5    # 5% error rate
        critical = 10   # 10% error rate
      }
      
      response_time = {
        warning  = 1000  # 1 second
        critical = 5000  # 5 seconds
      }
      
      availability = {
        warning  = 99.5  # 99.5% uptime
        critical = 99.0  # 99.0% uptime
      }
    }
    
    # Default monitoring labels
    monitoring_labels = {
      managed_by    = "port-infrastructure"
      alert_team    = "sre"
      escalation    = "standard"
    }
  }
}

# Compliance and audit configurations
locals {
  compliance_config = {
    # Required audit fields
    audit_fields = [
      "created_by",
      "created_at", 
      "modified_by",
      "modified_at",
      "change_reason"
    ]
    
    # Retention policies
    retention_policies = {
      audit_logs = "7 years"
      metrics_data = "2 years"
      incident_data = "5 years"
      compliance_reports = "10 years"
    }
    
    # Required compliance standards
    compliance_standards = {
      sox     = "Sarbanes-Oxley Act"
      pci_dss = "Payment Card Industry Data Security Standard"
      gdpr    = "General Data Protection Regulation"
      hipaa   = "Health Insurance Portability and Accountability Act"
      iso27001 = "ISO/IEC 27001"
    }
  }
}

# Output all utility configurations for use by other modules
output "validation_rules" {
  description = "Validation rules and regex patterns"
  value       = local.validation_rules
}

output "error_handling" {
  description = "Error handling configuration"
  value       = local.error_handling
}

output "webhook_config" {
  description = "Webhook configuration settings"
  value       = local.webhook_config
}

output "sync_schedules" {
  description = "Standard sync schedules for integrations"
  value       = local.sync_schedules
}

output "naming_conventions" {
  description = "Naming convention patterns"
  value       = local.naming_conventions
}

output "security_config" {
  description = "Security configuration settings"
  value       = local.security_config
}

output "monitoring_config" {
  description = "Monitoring and alerting configuration"
  value       = local.monitoring_config
}

output "compliance_config" {
  description = "Compliance and audit configuration"
  value       = local.compliance_config
}

output "standard_properties" {
  description = "Standard properties for all resources"
  value       = local.standard_properties
}

output "port_organization" {
  description = "Current Port organization information"
  value       = data.port_organization.current
}
