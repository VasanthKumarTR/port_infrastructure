---
mode: agent
---
**Objective**: Create a production-grade OpenTofu configuration for Port.io that serves as the source of truth for our software catalog and self-service portal. The configuration must be modular, secure, and able to fully recreate our Port environment.

Use https://docs.port.io/ documentation effectively to make the most out of it.

**Requirements**:
1. Use OpenTofu (tofu) v1.6+ with Port's native provider (hashicorp/port)
2. Implement all configurations through Port's API/SDK - NO Terraform
3. Structure code in modular files for:
   - Core blueprints (services, environments, resources)
   - Cloud integrations (AWS, Azure)
   - Dev tool integrations (GitHub, Azure DevOps)
   - Security integrations (Snyk)
   - DORA metrics collection
   - Self-service actions
4. Adhere to Port's best practices from documentation:
   - Relations instead of hardcoded identifiers
   - Required properties + enums for validation
   - Daily scheduled syncs for cloud resources
   - Approval workflows for production changes
   - Kubernetes exporter for cloud resources
   - RBAC with Port's permission system
5. Security measures:
   - Mark all sensitive variables as sensitive
   - Use vault references for secrets
   - Encrypt sensitive blueprint properties
   - Implement audit logging

**Repository Structure**:

Sample repository structure for the Port.io configuration:


port-iac/
├── main.tofu
├── providers.tofu
├── variables.tofu
├── outputs.tofu
├── integrations/
│ ├── github.tofu
│ ├── azure_devops.tofu
│ ├── snyk.tofu
│ ├── dora.tofu
│ ├── aws.tofu
│ └── azure.tofu
├── blueprints/
│ ├── core.tofu
│ ├── security.tofu
│ └── custom.tofu
├── actions/
│ ├── service_actions.tofu
│ └── approval_workflows.tofu
└── utils/
├── port_client.tofu
└── drift_detection.tofu


**Specific Instructions**:
1. **Core Blueprints** (blueprints/core.tofu):
   - Create modular blueprints for:
     * Microservice (identifier, language, owner, repo_link)
     * Environment (production/staging, region)
     * Cluster (EKS/AKS, version)
     * Repository (SCM type, url)
   - Implement relations: microservice → environment, microservice → repository
   - Add required enums: environment type, deployment tier

2. **GitHub Integration** (integrations/github.tofu):
   - Configure GitHub App integration using port_integration resource
   - Sync repositories as Port entities
   - Implement webhook for real-time updates
   - Map repository metadata to blueprint properties

3. **AWS Integration** (integrations/aws.tofu):
   - Set up AWS integration via Kubernetes exporter
   - Sync EKS clusters, RDS instances, S3 buckets
   - Daily full sync + EventBridge for real-time changes
   - Tag-based filtering for resources

4. **DORA Metrics** (integrations/dora.tofu):
   - Create DORA metrics blueprint with:
     * Deployment frequency
     * Lead time
     * Change failure rate
     * Recovery time
   - Implement relation to microservice blueprint
   - Configure calculation via GitHub Actions webhook

5. **Self-Service Actions** (actions/service_actions.tofu):
   - Create "Provision Microservice" action:
     * Trigger: CREATE
     * User inputs: service_name, language, environment
     * Approval workflow for production
     * Webhook to GitHub Actions pipeline
   - Add input validation rules
   - RBAC: restrict production access to senior engineers

6. **Security**:
   - Mark all credentials as sensitive variables
   - Use vault references: 
     `github_private_key = vault("secrets/github", "private_key")`
   - Enable audit logging for all resources
   - Encrypt sensitive blueprint properties

7. **Utility Module** (utils/port_client.tofu):
   - Create reusable port_client module for:
     * DRY integration setup
     * Standard error handling
     * Configuration validation

**Best Practices to Enforce**:
- Use versioned modules for reusability
- Implement drift detection with weekly audits
- Add automated tests for blueprint validation
- Document all resources using descriptions
- Set lifecycle management policies
- Configure automatic entity cleanup

**Example Snippet for Blueprint**:
```hcl
resource "port_blueprint" "microservice" {
  title       = "Microservice"
  icon        = "Microservice"
  description = "Deployable service component"
  identifier  = "microservice"
  
  properties = {
    "language" = {
      type        = "string"
      title       = "Language"
      enum       = ["go", "python", "typescript"]
      description = "Primary programming language"
      required   = true
    }
    "owner" = {
      type        = "string"
      title       = "Owner"
      format      = "email"
      description = "Service owner email"
      required   = true
    }
  }
  
  relations = {
    "environment" = {
      title     = "Environment"
      target    = port_blueprint.environment.identifier
      required  = true
      many      = false
    }
  }
}

Prompt Output Requirements:

    Generate complete OpenTofu configuration files

    Include detailed comments explaining each section

    Add usage instructions in README format

    Suggest CI/CD pipeline implementation

    Include validation checks for all resources

    Ensure modularity and reusability of components
    Follow Port.io's best practices and security guidelines
    Provide examples for each integration and blueprint
    Ensure all sensitive data is handled securely
    Use Port's API/SDK for all configurations
    Implement RBAC and approval workflows
    Include audit logging for all resources
    Document all resources and configurations
    Provide example usage for each module
    Ensure compliance with Port's best practices
    Include error handling and validation in utilities
    Provide example configurations for cloud integrations
    Ensure all configurations are modular and reusable
    Include example configurations for self-service actions

