# DORA Metrics Integration for Port.io
# Configures DORA (DevOps Research and Assessment) metrics collection and tracking

# DORA Metrics Blueprint
resource "port_blueprint" "dora_metrics" {
  title       = "DORA Metrics"
  icon        = "Chart"
  description = "DevOps Research and Assessment metrics for measuring team performance"
  identifier  = "dora_metrics"

  properties = {
    # Metric Identification
    "period" = {
      type        = "string"
      title       = "Measurement Period"
      enum        = ["daily", "weekly", "monthly", "quarterly"]
      description = "Time period for the metrics calculation"
      required    = true
    }
    
    "start_date" = {
      type        = "string"
      title       = "Start Date"
      format      = "date"
      description = "Start date of the measurement period"
      required    = true
    }
    
    "end_date" = {
      type        = "string"
      title       = "End Date"
      format      = "date"
      description = "End date of the measurement period"
      required    = true
    }
    
    # Deployment Frequency
    "deployment_frequency" = {
      type        = "number"
      title       = "Deployment Frequency"
      description = "Number of deployments per day/week/month"
      required    = true
    }
    
    "deployment_frequency_category" = {
      type        = "string"
      title       = "Deployment Frequency Category"
      enum        = ["on_demand", "daily", "weekly", "monthly", "less_than_monthly"]
      description = "DORA category for deployment frequency"
      required    = true
    }
    
    # Lead Time for Changes
    "lead_time_hours" = {
      type        = "number"
      title       = "Lead Time (Hours)"
      description = "Average time from commit to production deployment in hours"
      required    = true
    }
    
    "lead_time_category" = {
      type        = "string"
      title       = "Lead Time Category"
      enum        = ["less_than_one_hour", "one_day", "one_week", "one_month", "more_than_one_month"]
      description = "DORA category for lead time"
      required    = true
    }
    
    # Change Failure Rate
    "change_failure_rate" = {
      type        = "number"
      title       = "Change Failure Rate (%)"
      description = "Percentage of deployments that result in failures"
      required    = true
    }
    
    "change_failure_category" = {
      type        = "string"
      title       = "Change Failure Rate Category"
      enum        = ["0_to_15_percent", "16_to_30_percent", "31_to_45_percent", "46_to_60_percent", "over_60_percent"]
      description = "DORA category for change failure rate"
      required    = true
    }
    
    # Mean Time to Recovery
    "mttr_hours" = {
      type        = "number"
      title       = "Mean Time to Recovery (Hours)"
      description = "Average time to recover from failures in hours"
      required    = true
    }
    
    "mttr_category" = {
      type        = "string"
      title       = "MTTR Category"
      enum        = ["less_than_one_hour", "one_day", "one_week", "one_month", "more_than_one_month"]
      description = "DORA category for mean time to recovery"
      required    = true
    }
    
    # Overall Performance
    "overall_performance" = {
      type        = "string"
      title       = "Overall DORA Performance"
      enum        = ["elite", "high", "medium", "low"]
      description = "Overall DORA performance classification"
      required    = true
    }
    
    # Calculation Details
    "total_deployments" = {
      type        = "number"
      title       = "Total Deployments"
      description = "Total number of deployments in the period"
      required    = false
    }
    
    "failed_deployments" = {
      type        = "number"
      title       = "Failed Deployments"
      description = "Number of failed deployments in the period"
      required    = false
    }
    
    "total_incidents" = {
      type        = "number"
      title       = "Total Incidents"
      description = "Total number of incidents in the period"
      required    = false
    }
    
    "calculation_method" = {
      type        = "string"
      title       = "Calculation Method"
      enum        = ["automated", "manual", "estimated"]
      description = "How the metrics were calculated"
      required    = false
      default     = "automated"
    }
    
    "data_completeness" = {
      type        = "number"
      title       = "Data Completeness (%)"
      description = "Percentage of complete data used in calculations"
      required    = false
    }
    
    "notes" = {
      type        = "string"
      title       = "Notes"
      description = "Additional notes about the metrics or calculation"
      required    = false
    }
  }

  relations = {
    # DORA metrics are calculated for microservices
    "microservice" = {
      title     = "Microservice"
      target    = "microservice"
      required  = true
      many      = false
    }
    
    # DORA metrics can be associated with teams
    "team" = {
      title     = "Team"
      target    = "team"
      required  = false
      many      = false
    }
  }

  # Enable audit logging for metrics tracking
  change_log = {
    enabled = true
  }
}

# Incident Blueprint for MTTR calculation
resource "port_blueprint" "incident" {
  title       = "Incident"
  icon        = "Alert"
  description = "Production incidents for MTTR and change failure rate calculations"
  identifier  = "incident"

  properties = {
    "title" = {
      type        = "string"
      title       = "Incident Title"
      description = "Brief description of the incident"
      required    = true
    }
    
    "severity" = {
      type        = "string"
      title       = "Severity"
      enum        = ["critical", "high", "medium", "low"]
      description = "Severity level of the incident"
      required    = true
    }
    
    "status" = {
      type        = "string"
      title       = "Status"
      enum        = ["open", "investigating", "identified", "monitoring", "resolved", "closed"]
      description = "Current status of the incident"
      required    = true
    }
    
    "created_at" = {
      type        = "string"
      title       = "Created At"
      format      = "date-time"
      description = "When the incident was first reported"
      required    = true
    }
    
    "detected_at" = {
      type        = "string"
      title       = "Detected At"
      format      = "date-time"
      description = "When the incident was first detected"
      required    = false
    }
    
    "resolved_at" = {
      type        = "string"
      title       = "Resolved At"
      format      = "date-time"
      description = "When the incident was resolved"
      required    = false
    }
    
    "closed_at" = {
      type        = "string"
      title       = "Closed At"
      format      = "date-time"
      description = "When the incident was closed"
      required    = false
    }
    
    "resolution_time_minutes" = {
      type        = "number"
      title       = "Resolution Time (Minutes)"
      description = "Time taken to resolve the incident in minutes"
      required    = false
    }
    
    "caused_by_deployment" = {
      type        = "boolean"
      title       = "Caused by Deployment"
      description = "Whether the incident was caused by a recent deployment"
      required    = false
      default     = false
    }
    
    "root_cause" = {
      type        = "string"
      title       = "Root Cause"
      enum        = ["code_defect", "configuration_error", "infrastructure_failure", "dependency_failure", "human_error", "unknown"]
      description = "Root cause category of the incident"
      required    = false
    }
    
    "impact" = {
      type        = "string"
      title       = "Impact"
      enum        = ["service_unavailable", "performance_degraded", "feature_broken", "data_loss", "security_breach"]
      description = "Type of impact caused by the incident"
      required    = false
    }
    
    "assigned_to" = {
      type        = "string"
      title       = "Assigned To"
      format      = "email"
      description = "Person currently assigned to the incident"
      required    = false
    }
    
    "incident_commander" = {
      type        = "string"
      title       = "Incident Commander"
      format      = "email"
      description = "Person leading the incident response"
      required    = false
    }
    
    "postmortem_url" = {
      type        = "string"
      title       = "Postmortem URL"
      format      = "url"
      description = "Link to the incident postmortem document"
      required    = false
    }
  }

  relations = {
    # Incidents affect microservices
    "microservice" = {
      title     = "Microservice"
      target    = "microservice"
      required  = true
      many      = false
    }
    
    # Incidents can be related to deployments
    "deployment" = {
      title     = "Deployment"
      target    = "deployment"
      required  = false
      many      = false
    }
    
    # Incidents are handled by teams
    "team" = {
      title     = "Team"
      target    = "team"
      required  = false
      many      = false
    }
  }

  # Enable audit logging for incident tracking
  change_log = {
    enabled = true
  }
}

# DORA Metrics Calculation Action
resource "port_action" "calculate_dora_metrics" {
  title             = "Calculate DORA Metrics"
  identifier        = "calculate_dora_metrics"
  icon              = "Chart"
  description       = "Calculate DORA metrics for a microservice over a specified period"
  trigger           = "CREATE"
  
  invocation_method = {
    type = "WEBHOOK"
    url  = var.dora_webhook_url
    
    # Send microservice and time period data
    body = jsonencode({
      microservice_id = "{{ .entity.identifier }}"
      period         = "{{ .inputs.period }}"
      start_date     = "{{ .inputs.start_date }}"
      end_date       = "{{ .inputs.end_date }}"
    })
  }

  user_properties = {
    string_props = {
      "period" = {
        title       = "Measurement Period"
        description = "Time period for metrics calculation"
        enum        = ["weekly", "monthly", "quarterly"]
        default     = "monthly"
      }
      "start_date" = {
        title       = "Start Date"
        description = "Start date for measurement period (YYYY-MM-DD)"
        format      = "date"
      }
      "end_date" = {
        title       = "End Date"
        description = "End date for measurement period (YYYY-MM-DD)"
        format      = "date"
      }
    }
  }

  # Only allow team members to calculate metrics
  approval_notification = {
    type = "email"
    recipients = ["{{ .entity.properties.owner }}"]
  }
  
  # Require approval for quarterly metrics
  required_approval = "{{ .inputs.period == 'quarterly' }}"
}

# Automated DORA Metrics Collection Webhook
resource "port_action" "dora_webhook_handler" {
  title             = "DORA Metrics Webhook"
  identifier        = "dora_webhook_handler"
  icon              = "Webhook"
  description       = "Handle automated DORA metrics updates from CI/CD pipelines"
  trigger           = "WEBHOOK"
  
  webhook_method = {
    type = "WEBHOOK"
    url  = var.dora_collection_webhook_url
  }

  # No approval required for automated data collection
  approval_notification = {
    type = "email"
    recipients = [var.team_email]
  }
}
