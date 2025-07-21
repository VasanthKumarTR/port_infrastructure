# Custom blueprints for organization-specific needs
# These blueprints can be customized based on specific organizational requirements

# Team Blueprint
resource "port_blueprint" "team" {
  title       = "Team"
  icon        = "Team"
  description = "Development teams and their ownership information"
  identifier  = "team"

  properties = {
    "name" = {
      type        = "string"
      title       = "Team Name"
      description = "Name of the development team"
      required    = true
    }
    
    "description" = {
      type        = "string"
      title       = "Description"
      description = "Brief description of the team's responsibilities"
      required    = false
    }
    
    "lead_email" = {
      type        = "string"
      title       = "Team Lead Email"
      format      = "email"
      description = "Email of the team lead"
      required    = true
    }
    
    "slack_channel" = {
      type        = "string"
      title       = "Slack Channel"
      description = "Team's Slack channel for communication"
      required    = false
    }
    
    "oncall_schedule" = {
      type        = "string"
      title       = "On-call Schedule URL"
      format      = "url"
      description = "Link to the team's on-call schedule"
      required    = false
    }
    
    "members" = {
      type        = "array"
      title       = "Team Members"
      description = "List of team member emails"
      required    = false
    }
    
    "domain" = {
      type        = "string"
      title       = "Business Domain"
      enum        = ["platform", "product", "data", "security", "infrastructure", "mobile"]
      description = "Primary business domain the team works in"
      required    = true
    }
    
    "cost_center" = {
      type        = "string"
      title       = "Cost Center"
      description = "Budget/cost center code for the team"
      required    = false
    }
  }

  # Enable audit logging
  change_log = {
    enabled = var.enable_audit_logging
  }
}

# API Blueprint
resource "port_blueprint" "api" {
  title       = "API"
  icon        = "API"
  description = "REST and GraphQL APIs with their specifications and endpoints"
  identifier  = "api"

  properties = {
    "name" = {
      type        = "string"
      title       = "API Name"
      description = "Name of the API"
      required    = true
    }
    
    "version" = {
      type        = "string"
      title       = "API Version"
      description = "Current version of the API"
      required    = true
    }
    
    "type" = {
      type        = "string"
      title       = "API Type"
      enum        = ["rest", "graphql", "grpc", "soap"]
      description = "Type of API protocol"
      required    = true
    }
    
    "base_url" = {
      type        = "string"
      title       = "Base URL"
      format      = "url"
      description = "Base URL for the API"
      required    = true
    }
    
    "spec_url" = {
      type        = "string"
      title       = "Specification URL"
      format      = "url"
      description = "OpenAPI/GraphQL schema URL"
      required    = false
    }
    
    "documentation_url" = {
      type        = "string"
      title       = "Documentation URL"
      format      = "url"
      description = "API documentation URL"
      required    = false
    }
    
    "status" = {
      type        = "string"
      title       = "API Status"
      enum        = ["active", "deprecated", "beta", "alpha", "sunset"]
      description = "Current lifecycle status of the API"
      required    = true
      default     = "active"
    }
    
    "authentication_type" = {
      type        = "string"
      title       = "Authentication Type"
      enum        = ["bearer_token", "api_key", "oauth2", "basic_auth", "none"]
      description = "Authentication method used by the API"
      required    = true
    }
    
    "rate_limit" = {
      type        = "number"
      title       = "Rate Limit"
      description = "Requests per minute allowed"
      required    = false
    }
    
    "sla_uptime" = {
      type        = "number"
      title       = "SLA Uptime %"
      description = "Service Level Agreement uptime percentage"
      required    = false
    }
    
    "breaking_changes_policy" = {
      type        = "string"
      title       = "Breaking Changes Policy"
      description = "Policy for handling breaking changes"
      required    = false
    }
  }

  relations = {
    # APIs are provided by microservices
    "microservice" = {
      title     = "Microservice"
      target    = "microservice"
      required  = true
      many      = false
    }
    
    # APIs are owned by teams
    "team" = {
      title     = "Team"
      target    = port_blueprint.team.identifier
      required  = true
      many      = false
    }
  }

  # Enable audit logging
  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Database Blueprint
resource "port_blueprint" "database" {
  title       = "Database"
  icon        = "Database"
  description = "Database instances and their configuration"
  identifier  = "database"

  properties = {
    "name" = {
      type        = "string"
      title       = "Database Name"
      description = "Name of the database instance"
      required    = true
    }
    
    "type" = {
      type        = "string"
      title       = "Database Type"
      enum        = ["postgresql", "mysql", "mongodb", "redis", "elasticsearch", "dynamodb", "cassandra"]
      description = "Type of database engine"
      required    = true
    }
    
    "version" = {
      type        = "string"
      title       = "Database Version"
      description = "Version of the database engine"
      required    = true
    }
    
    "size" = {
      type        = "string"
      title       = "Instance Size"
      description = "Database instance size/tier"
      required    = false
    }
    
    "storage_size_gb" = {
      type        = "number"
      title       = "Storage Size (GB)"
      description = "Allocated storage size in gigabytes"
      required    = false
    }
    
    "backup_enabled" = {
      type        = "boolean"
      title       = "Backup Enabled"
      description = "Whether automated backups are enabled"
      required    = false
      default     = true
    }
    
    "backup_retention_days" = {
      type        = "number"
      title       = "Backup Retention Days"
      description = "Number of days to retain backups"
      required    = false
      default     = 7
    }
    
    "multi_az" = {
      type        = "boolean"
      title       = "Multi-AZ Deployment"
      description = "Whether the database is deployed across multiple availability zones"
      required    = false
      default     = false
    }
    
    "encryption_at_rest" = {
      type        = "boolean"
      title       = "Encryption at Rest"
      description = "Whether data is encrypted at rest"
      required    = false
      default     = true
    }
    
    "publicly_accessible" = {
      type        = "boolean"
      title       = "Publicly Accessible"
      description = "Whether the database is accessible from the internet"
      required    = false
      default     = false
    }
    
    "connection_string" = {
      type        = "string"
      title       = "Connection String"
      description = "Database connection string (without credentials)"
      required    = false
    }
    
    "monitoring_url" = {
      type        = "string"
      title       = "Monitoring URL"
      format      = "url"
      description = "Link to database monitoring dashboard"
      required    = false
    }
  }

  relations = {
    # Databases are used by microservices
    "microservice" = {
      title     = "Microservice"
      target    = "microservice"
      required  = false
      many      = true
    }
    
    # Databases are deployed in environments
    "environment" = {
      title     = "Environment"
      target    = "environment"
      required  = true
      many      = false
    }
    
    # Databases are owned by teams
    "team" = {
      title     = "Team"
      target    = port_blueprint.team.identifier
      required  = true
      many      = false
    }
  }

  # Enable audit logging
  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Deployment Blueprint
resource "port_blueprint" "deployment" {
  title       = "Deployment"
  icon        = "Deployment"
  description = "Service deployment instances with their status and metadata"
  identifier  = "deployment"

  properties = {
    "version" = {
      type        = "string"
      title       = "Deployment Version"
      description = "Version or tag being deployed"
      required    = true
    }
    
    "status" = {
      type        = "string"
      title       = "Deployment Status"
      enum        = ["pending", "in_progress", "success", "failed", "rolled_back"]
      description = "Current status of the deployment"
      required    = true
    }
    
    "deployed_at" = {
      type        = "string"
      title       = "Deployed At"
      format      = "date-time"
      description = "Timestamp when deployment was initiated"
      required    = true
    }
    
    "deployed_by" = {
      type        = "string"
      title       = "Deployed By"
      format      = "email"
      description = "Person who initiated the deployment"
      required    = true
    }
    
    "commit_sha" = {
      type        = "string"
      title       = "Commit SHA"
      description = "Git commit SHA being deployed"
      required    = false
    }
    
    "pipeline_url" = {
      type        = "string"
      title       = "Pipeline URL"
      format      = "url"
      description = "Link to the CI/CD pipeline run"
      required    = false
    }
    
    "rollback_version" = {
      type        = "string"
      title       = "Rollback Version"
      description = "Previous version to rollback to if needed"
      required    = false
    }
    
    "health_check_passed" = {
      type        = "boolean"
      title       = "Health Check Passed"
      description = "Whether post-deployment health checks passed"
      required    = false
    }
    
    "deployment_duration_minutes" = {
      type        = "number"
      title       = "Deployment Duration (minutes)"
      description = "How long the deployment took in minutes"
      required    = false
    }
    
    "notes" = {
      type        = "string"
      title       = "Deployment Notes"
      description = "Additional notes about the deployment"
      required    = false
    }
  }

  relations = {
    # Deployments are of microservices
    "microservice" = {
      title     = "Microservice"
      target    = "microservice"
      required  = true
      many      = false
    }
    
    # Deployments are to environments
    "environment" = {
      title     = "Environment"
      target    = "environment"
      required  = true
      many      = false
    }
  }

  # Enable audit logging
  change_log = {
    enabled = var.enable_audit_logging
  }
}
