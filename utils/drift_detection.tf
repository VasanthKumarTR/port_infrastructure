# Drift Detection and Monitoring for Port.io Infrastructure
# Implements automated detection of configuration drift and compliance monitoring

# Drift Detection Configuration Blueprint
resource "port_blueprint" "drift_detection" {
  title       = "Drift Detection"
  icon        = "Alert"
  description = "Configuration drift detection results and compliance monitoring"
  identifier  = "drift_detection"

  properties = {
    "scan_id" = {
      type        = "string"
      title       = "Scan ID"
      description = "Unique identifier for the drift detection scan"
      required    = true
    }
    
    "scan_date" = {
      type        = "string"
      title       = "Scan Date"
      format      = "date-time"
      description = "When the drift detection scan was performed"
      required    = true
    }
    
    "scan_type" = {
      type        = "string"
      title       = "Scan Type"
      enum        = ["full", "incremental", "targeted", "compliance"]
      description = "Type of drift detection scan"
      required    = true
    }
    
    "status" = {
      type        = "string"
      title       = "Scan Status"
      enum        = ["completed", "failed", "in_progress", "cancelled"]
      description = "Current status of the drift scan"
      required    = true
    }
    
    # Drift Results
    "drift_detected" = {
      type        = "boolean"
      title       = "Drift Detected"
      description = "Whether configuration drift was detected"
      required    = true
      default     = false
    }
    
    "drift_count" = {
      type        = "number"
      title       = "Number of Drifts"
      description = "Total number of configuration drifts detected"
      required    = false
      default     = 0
    }
    
    "critical_drifts" = {
      type        = "number"
      title       = "Critical Drifts"
      description = "Number of critical configuration drifts"
      required    = false
      default     = 0
    }
    
    "high_drifts" = {
      type        = "number"
      title       = "High Priority Drifts"
      description = "Number of high priority configuration drifts"
      required    = false
      default     = 0
    }
    
    "medium_drifts" = {
      type        = "number"
      title       = "Medium Priority Drifts"
      description = "Number of medium priority configuration drifts"
      required    = false
      default     = 0
    }
    
    "low_drifts" = {
      type        = "number"
      title       = "Low Priority Drifts"
      description = "Number of low priority configuration drifts"
      required    = false
      default     = 0
    }
    
    # Compliance Information
    "compliance_score" = {
      type        = "number"
      title       = "Compliance Score (%)"
      description = "Overall compliance score as a percentage"
      required    = false
    }
    
    "policy_violations" = {
      type        = "array"
      title       = "Policy Violations"
      description = "List of policy violations found during scan"
      required    = false
    }
    
    # Remediation Information
    "auto_remediated" = {
      type        = "number"
      title       = "Auto Remediated"
      description = "Number of drifts automatically remediated"
      required    = false
      default     = 0
    }
    
    "manual_remediation_required" = {
      type        = "number"
      title       = "Manual Remediation Required"
      description = "Number of drifts requiring manual intervention"
      required    = false
      default     = 0
    }
    
    "remediation_plan_url" = {
      type        = "string"
      title       = "Remediation Plan URL"
      format      = "url"
      description = "Link to detailed remediation plan"
      required    = false
    }
    
    # Scan Configuration
    "scope" = {
      type        = "string"
      title       = "Scan Scope"
      enum        = ["all", "blueprints", "integrations", "actions", "entities"]
      description = "Scope of the drift detection scan"
      required    = true
    }
    
    "baseline_version" = {
      type        = "string"
      title       = "Baseline Version"
      description = "Version of configuration used as baseline"
      required    = false
    }
    
    "scan_duration_seconds" = {
      type        = "number"
      title       = "Scan Duration (seconds)"
      description = "How long the scan took to complete"
      required    = false
    }
    
    "next_scan_due" = {
      type        = "string"
      title       = "Next Scan Due"
      format      = "date-time"
      description = "When the next drift detection scan is scheduled"
      required    = false
    }
  }

  # Enable audit logging for drift detection
  change_log = {
    enabled = true
  }
}

# Drift Detection Action
resource "port_action" "run_drift_detection" {
  title             = "Run Drift Detection"
  identifier        = "run_drift_detection"
  icon              = "Alert"
  description       = "Execute drift detection scan to identify configuration changes"
  trigger           = "CREATE"
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "drift-detection.yml"
      workflow_inputs = jsonencode({
        scan_type        = "{{ .inputs.scan_type }}"
        scope           = "{{ .inputs.scope }}"
        auto_remediate  = "{{ .inputs.auto_remediate }}"
        notify_teams    = "{{ .inputs.notify_teams }}"
        port_client_id  = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  user_properties = {
    string_props = {
      "scan_type" = {
        title       = "Scan Type"
        description = "Type of drift detection to perform"
        enum        = ["full", "incremental", "targeted", "compliance"]
        default     = "incremental"
      }
      
      "scope" = {
        title       = "Scan Scope"
        description = "What to include in the drift detection scan"
        enum        = ["all", "blueprints", "integrations", "actions", "entities"]
        default     = "all"
      }
    }
    
    boolean_props = {
      "auto_remediate" = {
        title       = "Auto Remediate"
        description = "Automatically fix low-risk configuration drifts"
        default     = false
      }
      
      "notify_teams" = {
        title       = "Notify Teams"
        description = "Send notifications to affected teams"
        default     = true
      }
    }
  }

  # No approval required for drift detection scans
  approval_notification = {
    type = "email"
    recipients = [var.team_email]
  }
  
  required_approval = false
  
  # Any team member can run drift detection
  required_roles = ["developer", "senior_engineer", "tech_lead", "sre"]
}

# Scheduled Drift Detection
resource "port_action" "scheduled_drift_detection" {
  title             = "Scheduled Drift Detection"
  identifier        = "scheduled_drift_detection"
  icon              = "Clock"
  description       = "Automatically scheduled drift detection scan"
  trigger           = "TIMER"
  
  timer_property = {
    cron_expression = var.drift_detection_schedule
  }
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "scheduled-drift-detection.yml"
      workflow_inputs = jsonencode({
        scan_type        = "full"
        scope           = "all"
        auto_remediate  = "true"
        notify_teams    = "true"
        port_client_id  = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  # Notifications for scheduled scans
  approval_notification = {
    type = "slack"
    recipients = ["#infrastructure"]
  }
  
  required_approval = false
}

# Compliance Monitoring Action
resource "port_action" "compliance_check" {
  title             = "Run Compliance Check"
  identifier        = "run_compliance_check"
  icon              = "CheckCircle"
  description       = "Execute compliance verification against organizational policies"
  trigger           = "CREATE"
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "compliance-check.yml"
      workflow_inputs = jsonencode({
        standards       = "{{ .inputs.standards }}"
        scope          = "{{ .inputs.scope }}"
        generate_report = "{{ .inputs.generate_report }}"
        port_client_id = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  user_properties = {
    array_props = {
      "standards" = {
        title       = "Compliance Standards"
        description = "Which compliance standards to check against"
        enum        = ["sox", "pci_dss", "gdpr", "hipaa", "iso27001", "nist", "cis"]
        default     = ["sox", "pci_dss"]
      }
    }
    
    string_props = {
      "scope" = {
        title       = "Check Scope"
        description = "Scope of compliance verification"
        enum        = ["all", "production_only", "sensitive_data", "security_controls"]
        default     = "all"
      }
    }
    
    boolean_props = {
      "generate_report" = {
        title       = "Generate Report"
        description = "Generate detailed compliance report"
        default     = true
      }
    }
  }

  # Compliance checks may require approval for comprehensive scans
  approval_notification = {
    type = "email"
    recipients = ["compliance@company.com", "security@company.com"]
  }
  
  required_approval = "{{ .inputs.scope == 'all' and .inputs.generate_report == true }}"
  
  # Only compliance and security team members can run comprehensive checks
  required_roles = ["compliance_officer", "security_engineer", "tech_lead", "sre"]
}

# Configuration Baseline Management
resource "port_action" "create_baseline" {
  title             = "Create Configuration Baseline"
  identifier        = "create_configuration_baseline"
  icon              = "Save"
  description       = "Create a new configuration baseline for future drift detection"
  trigger           = "CREATE"
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "create-baseline.yml"
      workflow_inputs = jsonencode({
        baseline_name   = "{{ .inputs.baseline_name }}"
        description     = "{{ .inputs.description }}"
        scope          = "{{ .inputs.scope }}"
        port_client_id = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  user_properties = {
    string_props = {
      "baseline_name" = {
        title       = "Baseline Name"
        description = "Name for the configuration baseline"
        pattern     = "^[a-z][a-z0-9-]*[a-z0-9]$"
      }
      
      "description" = {
        title       = "Description"
        description = "Description of what this baseline represents"
      }
      
      "scope" = {
        title       = "Scope"
        description = "What to include in the baseline"
        enum        = ["all", "blueprints", "integrations", "actions"]
        default     = "all"
      }
    }
  }

  # Creating baselines requires approval
  approval_notification = {
    type = "email"
    recipients = [var.team_email]
  }
  
  required_approval = true
  
  # Only senior team members can create baselines
  required_roles = ["senior_engineer", "tech_lead", "sre", "architect"]
}

# Drift Remediation Action
resource "port_action" "remediate_drift" {
  title             = "Remediate Configuration Drift"
  identifier        = "remediate_configuration_drift"
  icon              = "Repair"
  description       = "Apply automated remediation for detected configuration drift"
  trigger           = "DAY-2"
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "remediate-drift.yml"
      workflow_inputs = jsonencode({
        drift_id        = "{{ .entity.identifier }}"
        remediation_type = "{{ .inputs.remediation_type }}"
        auto_approve    = "{{ .inputs.auto_approve }}"
        dry_run        = "{{ .inputs.dry_run }}"
        port_client_id = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  user_properties = {
    string_props = {
      "remediation_type" = {
        title       = "Remediation Type"
        description = "Type of remediation to apply"
        enum        = ["automatic", "manual", "revert", "update_baseline"]
        default     = "automatic"
      }
    }
    
    boolean_props = {
      "dry_run" = {
        title       = "Dry Run"
        description = "Preview changes without applying them"
        default     = true
      }
      
      "auto_approve" = {
        title       = "Auto Approve"
        description = "Skip manual approval for low-risk changes"
        default     = false
      }
    }
  }

  # Remediation requires approval unless it's a dry run
  approval_notification = {
    type = "email"
    recipients = [var.team_email]
  }
  
  required_approval = "{{ .inputs.dry_run == false and .inputs.auto_approve == false }}"
  
  # Only authorized team members can remediate drift
  required_roles = ["senior_engineer", "tech_lead", "sre"]
}
