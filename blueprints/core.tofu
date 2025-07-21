# Core blueprints for Port.io software catalog
# These blueprints form the foundation of the software catalog structure

# Microservice Blueprint
resource "port_blueprint" "microservice" {
  title       = "Microservice"
  icon        = "Microservice"
  description = "Deployable service component with ownership and deployment information"
  identifier  = "microservice"

  properties = {
    # Service Identity
    "identifier" = {
      type        = "string"
      title       = "Service Identifier"
      description = "Unique identifier for the microservice"
      required    = true
    }
    
    # Technical Details
    "language" = {
      type        = "string"
      title       = "Programming Language"
      enum        = ["go", "python", "typescript", "java", "rust", "csharp"]
      description = "Primary programming language used"
      required    = true
    }
    
    "framework" = {
      type        = "string"
      title       = "Framework"
      description = "Framework or library used (e.g., FastAPI, Express, Spring Boot)"
      required    = false
    }
    
    # Ownership and Governance
    "owner" = {
      type        = "string"
      title       = "Service Owner"
      format      = "email"
      description = "Primary owner responsible for the service"
      required    = true
    }
    
    "team" = {
      type        = "string"
      title       = "Owning Team"
      description = "Team responsible for maintaining the service"
      required    = true
    }
    
    # Repository Information
    "repo_url" = {
      type        = "string"
      title       = "Repository URL"
      format      = "url"
      description = "Source code repository URL"
      required    = true
    }
    
    # Deployment Configuration
    "deployment_tier" = {
      type        = "string"
      title       = "Deployment Tier"
      enum        = ["critical", "high", "medium", "low"]
      description = "Service criticality level for deployment strategies"
      required    = true
      default     = "medium"
    }
    
    "health_check_url" = {
      type        = "string"
      title       = "Health Check URL"
      format      = "url"
      description = "Health check endpoint for monitoring"
      required    = false
    }
    
    # Documentation
    "documentation_url" = {
      type        = "string"
      title       = "Documentation URL"
      format      = "url"
      description = "Link to service documentation"
      required    = false
    }
    
    "api_spec_url" = {
      type        = "string"
      title       = "API Specification URL"
      format      = "url"
      description = "OpenAPI/Swagger specification URL"
      required    = false
    }
    
    # Compliance and Security
    "pci_compliant" = {
      type        = "boolean"
      title       = "PCI Compliant"
      description = "Whether the service handles PCI data"
      required    = false
      default     = false
    }
    
    "data_classification" = {
      type        = "string"
      title       = "Data Classification"
      enum        = ["public", "internal", "confidential", "restricted"]
      description = "Classification of data handled by the service"
      required    = true
      default     = "internal"
    }
  }

  relations = {
    # Service is deployed to environments
    "environment" = {
      title     = "Environment"
      target    = port_blueprint.environment.identifier
      required  = false
      many      = true
    }
    
    # Service is stored in repositories
    "repository" = {
      title     = "Repository"
      target    = port_blueprint.repository.identifier
      required  = true
      many      = false
    }
  }

  # Enable audit logging
  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Environment Blueprint
resource "port_blueprint" "environment" {
  title       = "Environment"
  icon        = "Environment"
  description = "Deployment environment for services (production, staging, development)"
  identifier  = "environment"

  properties = {
    "name" = {
      type        = "string"
      title       = "Environment Name"
      description = "Human-readable environment name"
      required    = true
    }
    
    "type" = {
      type        = "string"
      title       = "Environment Type"
      enum        = ["production", "staging", "development", "testing", "sandbox"]
      description = "Type of environment"
      required    = true
    }
    
    "region" = {
      type        = "string"
      title       = "Cloud Region"
      description = "Cloud provider region where environment is deployed"
      required    = true
    }
    
    "cloud_provider" = {
      type        = "string"
      title       = "Cloud Provider"
      enum        = ["aws", "azure", "gcp", "on-premise"]
      description = "Cloud provider hosting the environment"
      required    = true
    }
    
    "url" = {
      type        = "string"
      title       = "Environment URL"
      format      = "url"
      description = "Base URL for the environment"
      required    = false
    }
    
    "monitoring_url" = {
      type        = "string"
      title       = "Monitoring Dashboard URL"
      format      = "url"
      description = "Link to monitoring dashboard for this environment"
      required    = false
    }
    
    "requires_approval" = {
      type        = "boolean"
      title       = "Requires Approval"
      description = "Whether deployments to this environment require approval"
      required    = false
      default     = true
    }
  }

  relations = {
    # Environment runs on clusters
    "cluster" = {
      title     = "Cluster"
      target    = port_blueprint.cluster.identifier
      required  = true
      many      = false
    }
  }

  # Enable audit logging
  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Cluster Blueprint
resource "port_blueprint" "cluster" {
  title       = "Cluster"
  icon        = "Cluster"
  description = "Kubernetes or container orchestration cluster"
  identifier  = "cluster"

  properties = {
    "name" = {
      type        = "string"
      title       = "Cluster Name"
      description = "Name of the cluster"
      required    = true
    }
    
    "type" = {
      type        = "string"
      title       = "Cluster Type"
      enum        = ["eks", "aks", "gke", "self-managed"]
      description = "Type of Kubernetes cluster"
      required    = true
    }
    
    "version" = {
      type        = "string"
      title       = "Kubernetes Version"
      description = "Kubernetes version running on the cluster"
      required    = true
    }
    
    "region" = {
      type        = "string"
      title       = "Region"
      description = "Cloud region where cluster is deployed"
      required    = true
    }
    
    "node_count" = {
      type        = "number"
      title       = "Node Count"
      description = "Number of nodes in the cluster"
      required    = false
    }
    
    "endpoint" = {
      type        = "string"
      title       = "Cluster Endpoint"
      format      = "url"
      description = "Kubernetes API endpoint"
      required    = false
    }
    
    "monitoring_enabled" = {
      type        = "boolean"
      title       = "Monitoring Enabled"
      description = "Whether monitoring is configured for the cluster"
      required    = false
      default     = true
    }
    
    "auto_scaling_enabled" = {
      type        = "boolean"
      title       = "Auto Scaling Enabled"
      description = "Whether cluster auto-scaling is enabled"
      required    = false
      default     = false
    }
  }

  # Enable audit logging
  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Repository Blueprint
resource "port_blueprint" "repository" {
  title       = "Repository"
  icon        = "Git"
  description = "Source code repository with SCM information"
  identifier  = "repository"

  properties = {
    "name" = {
      type        = "string"
      title       = "Repository Name"
      description = "Name of the repository"
      required    = true
    }
    
    "scm_type" = {
      type        = "string"
      title       = "SCM Type"
      enum        = ["github", "azure_devops", "gitlab", "bitbucket"]
      description = "Source control management system"
      required    = true
    }
    
    "url" = {
      type        = "string"
      title       = "Repository URL"
      format      = "url"
      description = "Full URL to the repository"
      required    = true
    }
    
    "default_branch" = {
      type        = "string"
      title       = "Default Branch"
      description = "Default branch name (usually main or master)"
      required    = true
      default     = "main"
    }
    
    "visibility" = {
      type        = "string"
      title       = "Visibility"
      enum        = ["public", "private", "internal"]
      description = "Repository visibility level"
      required    = true
      default     = "private"
    }
    
    "language" = {
      type        = "string"
      title       = "Primary Language"
      description = "Primary programming language in the repository"
      required    = false
    }
    
    "license" = {
      type        = "string"
      title       = "License"
      description = "Software license for the repository"
      required    = false
    }
    
    "topics" = {
      type        = "array"
      title       = "Topics"
      description = "Topics/tags associated with the repository"
      required    = false
    }
    
    "created_at" = {
      type        = "string"
      title       = "Created At"
      format      = "date-time"
      description = "Repository creation timestamp"
      required    = false
    }
    
    "last_commit_date" = {
      type        = "string"
      title       = "Last Commit Date"
      format      = "date-time"
      description = "Date of the last commit"
      required    = false
    }
  }

  # Enable audit logging
  change_log = {
    enabled = var.enable_audit_logging
  }
}
