# Self-Service Actions for Port.io
# Configures automated workflows and approval processes for service provisioning

# Provision Microservice Action
resource "port_action" "provision_microservice" {
  title             = "Provision New Microservice"
  identifier        = "provision_microservice"
  icon              = "Microservice"
  description       = "Create a new microservice with repository, CI/CD pipeline, and deployment configuration"
  trigger           = "CREATE"
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "provision-microservice.yml"
      workflow_inputs = jsonencode({
        service_name     = "{{ .inputs.service_name }}"
        language         = "{{ .inputs.language }}"
        framework        = "{{ .inputs.framework }}"
        environment      = "{{ .inputs.environment }}"
        owner_email      = "{{ .inputs.owner_email }}"
        team             = "{{ .inputs.team }}"
        deployment_tier  = "{{ .inputs.deployment_tier }}"
        database_required = "{{ .inputs.database_required }}"
        api_type         = "{{ .inputs.api_type }}"
        port_client_id   = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  user_properties = {
    string_props = {
      "service_name" = {
        title       = "Service Name"
        description = "Name of the microservice (kebab-case, e.g., user-authentication)"
        pattern     = "^[a-z][a-z0-9-]*[a-z0-9]$"
      }
      
      "language" = {
        title       = "Programming Language"
        description = "Primary programming language for the service"
        enum        = ["go", "python", "typescript", "java", "rust", "csharp"]
      }
      
      "framework" = {
        title       = "Framework"
        description = "Framework to use for the service"
        enum        = ["fastapi", "gin", "express", "spring-boot", "actix-web", "asp-net-core"]
      }
      
      "environment" = {
        title       = "Target Environment"
        description = "Initial deployment environment"
        enum        = ["development", "staging", "production"]
        default     = "development"
      }
      
      "owner_email" = {
        title       = "Service Owner Email"
        description = "Email of the person responsible for this service"
        format      = "email"
      }
      
      "team" = {
        title       = "Owning Team"
        description = "Team responsible for maintaining the service"
        enum        = var.available_teams
      }
      
      "deployment_tier" = {
        title       = "Deployment Tier"
        description = "Service criticality level"
        enum        = ["critical", "high", "medium", "low"]
        default     = "medium"
      }
      
      "api_type" = {
        title       = "API Type"
        description = "Type of API the service will expose"
        enum        = ["rest", "graphql", "grpc", "none"]
        default     = "rest"
      }
    }
    
    boolean_props = {
      "database_required" = {
        title       = "Database Required"
        description = "Whether the service needs a database"
        default     = true
      }
      
      "monitoring_enabled" = {
        title       = "Enable Monitoring"
        description = "Enable monitoring and alerting for the service"
        default     = true
      }
      
      "security_scan_enabled" = {
        title       = "Enable Security Scanning"
        description = "Enable automated security scanning"
        default     = true
      }
    }
  }

  # Approval workflow for production deployments
  approval_notification = {
    type = "email"
    recipients = var.approval_recipients
  }
  
  # Require approval for critical services or production environment
  required_approval = "{{ .inputs.deployment_tier == 'critical' or .inputs.environment == 'production' }}"
  
  # RBAC - restrict production access to senior engineers
  required_roles = ["developer", "senior_engineer", "tech_lead"]
}

# Deploy Service Action
resource "port_action" "deploy_service" {
  title             = "Deploy Service"
  identifier        = "deploy_service"
  icon              = "Deployment"
  description       = "Deploy a microservice to a specified environment"
  trigger           = "DAY-2"
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "deploy-service.yml"
      workflow_inputs = jsonencode({
        microservice_id = "{{ .entity.identifier }}"
        environment     = "{{ .inputs.environment }}"
        version        = "{{ .inputs.version }}"
        force_deploy   = "{{ .inputs.force_deploy }}"
        rollback_on_failure = "{{ .inputs.rollback_on_failure }}"
        port_client_id = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  user_properties = {
    string_props = {
      "environment" = {
        title       = "Target Environment"
        description = "Environment to deploy to"
        enum        = ["development", "staging", "production"]
      }
      
      "version" = {
        title       = "Version"
        description = "Version/tag to deploy (leave empty for latest)"
        default     = "latest"
      }
    }
    
    boolean_props = {
      "force_deploy" = {
        title       = "Force Deploy"
        description = "Force deployment even if health checks fail"
        default     = false
      }
      
      "rollback_on_failure" = {
        title       = "Rollback on Failure"
        description = "Automatically rollback if deployment fails"
        default     = true
      }
    }
  }

  # Approval required for production deployments
  approval_notification = {
    type = "email"
    recipients = ["{{ .entity.properties.owner }}"]
  }
  
  required_approval = "{{ .inputs.environment == 'production' }}"
  
  # Only service owners and team members can deploy
  required_roles = ["developer", "senior_engineer", "tech_lead"]
}

# Rollback Service Action
resource "port_action" "rollback_service" {
  title             = "Rollback Service"
  identifier        = "rollback_service"
  icon              = "Undo"
  description       = "Rollback a microservice to a previous version"
  trigger           = "DAY-2"
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "rollback-service.yml"
      workflow_inputs = jsonencode({
        microservice_id = "{{ .entity.identifier }}"
        environment     = "{{ .inputs.environment }}"
        target_version  = "{{ .inputs.target_version }}"
        port_client_id  = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  user_properties = {
    string_props = {
      "environment" = {
        title       = "Environment"
        description = "Environment to rollback in"
        enum        = ["development", "staging", "production"]
      }
      
      "target_version" = {
        title       = "Target Version"
        description = "Version to rollback to"
      }
    }
  }

  # Always require approval for rollbacks
  approval_notification = {
    type = "email"
    recipients = ["{{ .entity.properties.owner }}", var.team_email]
  }
  
  required_approval = true
  
  # Only senior team members can perform rollbacks
  required_roles = ["senior_engineer", "tech_lead", "sre"]
}

# Scale Service Action
resource "port_action" "scale_service" {
  title             = "Scale Service"
  identifier        = "scale_service"
  icon              = "Scale"
  description       = "Scale a microservice up or down in a specified environment"
  trigger           = "DAY-2"
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "scale-service.yml"
      workflow_inputs = jsonencode({
        microservice_id = "{{ .entity.identifier }}"
        environment     = "{{ .inputs.environment }}"
        replicas       = "{{ .inputs.replicas }}"
        cpu_limit      = "{{ .inputs.cpu_limit }}"
        memory_limit   = "{{ .inputs.memory_limit }}"
        port_client_id = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  user_properties = {
    string_props = {
      "environment" = {
        title       = "Environment"
        description = "Environment to scale in"
        enum        = ["development", "staging", "production"]
      }
      
      "replicas" = {
        title       = "Number of Replicas"
        description = "Number of service instances to run"
        pattern     = "^[1-9][0-9]*$"
      }
      
      "cpu_limit" = {
        title       = "CPU Limit"
        description = "CPU limit per replica (e.g., 500m, 1, 2)"
        default     = "500m"
      }
      
      "memory_limit" = {
        title       = "Memory Limit"
        description = "Memory limit per replica (e.g., 512Mi, 1Gi, 2Gi)"
        default     = "512Mi"
      }
    }
  }

  # Require approval for production scaling
  approval_notification = {
    type = "email"
    recipients = ["{{ .entity.properties.owner }}"]
  }
  
  required_approval = "{{ .inputs.environment == 'production' and (.inputs.replicas | tonumber) > 5 }}"
  
  # Only team members can scale services
  required_roles = ["developer", "senior_engineer", "tech_lead", "sre"]
}

# Create Database Action
resource "port_action" "create_database" {
  title             = "Create Database"
  identifier        = "create_database"
  icon              = "Database"
  description       = "Create a new database instance for a microservice"
  trigger           = "CREATE"
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "create-database.yml"
      workflow_inputs = jsonencode({
        database_name   = "{{ .inputs.database_name }}"
        database_type   = "{{ .inputs.database_type }}"
        environment     = "{{ .inputs.environment }}"
        size           = "{{ .inputs.size }}"
        backup_enabled = "{{ .inputs.backup_enabled }}"
        multi_az       = "{{ .inputs.multi_az }}"
        microservice_id = "{{ .inputs.microservice_id }}"
        port_client_id = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  user_properties = {
    string_props = {
      "database_name" = {
        title       = "Database Name"
        description = "Name of the database instance"
        pattern     = "^[a-z][a-z0-9-]*[a-z0-9]$"
      }
      
      "database_type" = {
        title       = "Database Type"
        description = "Type of database engine"
        enum        = ["postgresql", "mysql", "mongodb", "redis"]
      }
      
      "environment" = {
        title       = "Environment"
        description = "Environment to create database in"
        enum        = ["development", "staging", "production"]
      }
      
      "size" = {
        title       = "Instance Size"
        description = "Database instance size"
        enum        = ["small", "medium", "large", "xlarge"]
        default     = "small"
      }
      
      "microservice_id" = {
        title       = "Microservice"
        description = "Microservice that will use this database"
        enum_from_port = "microservice"
      }
    }
    
    boolean_props = {
      "backup_enabled" = {
        title       = "Enable Backups"
        description = "Enable automated backups"
        default     = true
      }
      
      "multi_az" = {
        title       = "Multi-AZ Deployment"
        description = "Deploy across multiple availability zones"
        default     = false
      }
    }
  }

  # Require approval for production databases
  approval_notification = {
    type = "email"
    recipients = var.approval_recipients
  }
  
  required_approval = "{{ .inputs.environment == 'production' }}"
  
  # Only senior team members can create databases
  required_roles = ["senior_engineer", "tech_lead", "sre", "dba"]
}
