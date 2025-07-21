# Port.io Infrastructure as Code

A comprehensive OpenTofu configuration for managing Port.io software catalog and self-service portal as infrastructure as code.

## 🚀 Overview

This repository contains a production-ready OpenTofu configuration that implements Port.io as your single source of truth for software catalog management. It provides:

- **Complete Blueprint Architecture**: Microservices, environments, teams, APIs, databases, and more
- **Multi-Cloud Integrations**: AWS, Azure, GitHub, Azure DevOps, Snyk
- **DORA Metrics**: Automated DevOps performance tracking
- **Self-Service Actions**: Automated provisioning and deployment workflows
- **Security & Compliance**: Vulnerability tracking, compliance monitoring, audit logging
- **Drift Detection**: Automated configuration drift detection and remediation

## 📁 Repository Structure

```
port-iac/
├── main.tofu                    # Main orchestration file
├── providers.tofu              # Provider configurations
├── variables.tofu              # Input variables
├── outputs.tofu                # Output values
├── terraform.tfvars.example    # Example variable values
├── 
├── blueprints/                 # Port blueprints
│   ├── core.tofu              # Core blueprints (microservice, environment, etc.)
│   ├── security.tofu          # Security-focused blueprints
│   ├── custom.tofu            # Organization-specific blueprints
│   ├── variables.tofu         # Blueprint variables
│   └── outputs.tofu           # Blueprint outputs
├── 
├── integrations/              # External system integrations
│   ├── github/                # GitHub integration
│   │   ├── github.tofu
│   │   ├── variables.tofu
│   │   └── outputs.tofu
│   ├── aws.tofu              # AWS cloud integration
│   ├── azure.tofu            # Azure cloud integration
│   ├── azure_devops.tofu     # Azure DevOps integration
│   ├── snyk.tofu             # Snyk security integration
│   └── dora.tofu             # DORA metrics integration
├── 
├── actions/                   # Self-service actions
│   ├── service_actions.tofu   # Service provisioning actions
│   └── approval_workflows.tofu # Approval workflow definitions
├── 
├── utils/                     # Utility modules
│   ├── port_client.tofu       # Port client utilities
│   └── drift_detection.tofu   # Drift detection configuration
├── 
├── docs/                      # Documentation
│   ├── SETUP.md              # Setup instructions
│   ├── BLUEPRINTS.md         # Blueprint documentation
│   ├── INTEGRATIONS.md       # Integration documentation
│   └── ACTIONS.md            # Actions documentation
├── 
├── examples/                  # Example configurations
│   ├── terraform.tfvars.prod
│   ├── terraform.tfvars.staging
│   └── terraform.tfvars.dev
├── 
└── .github/                   # GitHub workflows
    └── workflows/
        ├── deploy.yml         # Deployment workflow
        ├── drift-detection.yml
        ├── provision-microservice.yml
        └── security-scan.yml
```

## 🛠️ Prerequisites

### Required Tools

- **OpenTofu** v1.6+ ([Installation Guide](https://opentofu.org/docs/intro/install/))
- **Port.io Account** with Admin access
- **Cloud Accounts** (AWS, Azure) with appropriate permissions
- **GitHub App** for repository integration
- **Azure DevOps** personal access token (if using)
- **Snyk Account** for security scanning (if using)

### Required Permissions

#### Port.io
- Admin access to create blueprints, integrations, and actions
- API credentials (Client ID & Secret)

#### AWS
- IAM permissions for EKS, RDS, S3, Lambda, EC2 management
- EventBridge permissions for real-time sync

#### Azure
- Service Principal with Contributor role
- Azure DevOps permissions for project access

#### GitHub
- GitHub App with repository read permissions
- Webhook creation permissions

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd port-infrastructure
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars` with your credentials:

```hcl
# Port.io Configuration
port_client_id     = "your-port-client-id"
port_client_secret = "your-port-client-secret"

# Environment
environment = "prod"
team_email  = "platform@company.com"

# AWS Configuration
aws_access_key_id     = "your-aws-access-key"
aws_secret_access_key = "your-aws-secret-key"
aws_region           = "us-west-2"

# GitHub Configuration
github_app_id          = "your-github-app-id"
github_private_key     = "-----BEGIN RSA PRIVATE KEY-----\n..."
github_installation_id = "your-installation-id"

# Additional integrations...
```

### 3. Initialize and Deploy

```bash
# Initialize OpenTofu
tofu init

# Plan the deployment
tofu plan

# Apply the configuration
tofu apply
```

### 4. Verify Deployment

After successful deployment, check your Port.io organization:

1. **Blueprints**: Verify all blueprints are created
2. **Integrations**: Check that integrations are syncing
3. **Actions**: Test self-service actions
4. **Entities**: Confirm entities are being populated

## 📋 Core Blueprints

### Microservice Blueprint
Central blueprint for tracking deployable services with:
- **Identity**: Service name, identifier, language, framework
- **Ownership**: Owner email, team assignment
- **Repository**: Source code location and metadata
- **Deployment**: Tier classification, health checks
- **Compliance**: Data classification, PCI compliance status

### Environment Blueprint
Deployment environments with:
- **Configuration**: Environment type, region, cloud provider
- **Access Control**: Approval requirements, monitoring setup
- **Relations**: Linked to clusters and microservices

### Additional Blueprints
- **Repository**: Source code repositories with SCM details
- **Team**: Development teams and ownership information
- **API**: REST/GraphQL APIs with specifications
- **Database**: Database instances with configuration
- **Deployment**: Deployment tracking and history
- **Security Scan**: Vulnerability scan results
- **DORA Metrics**: DevOps performance metrics

## 🔗 Integrations

### GitHub Integration
- **Repository Sync**: Automatic repository discovery and metadata sync
- **Pull Request Tracking**: For DORA metrics calculation
- **Workflow Monitoring**: CI/CD pipeline execution tracking
- **Real-time Updates**: Webhook-based immediate synchronization

### AWS Integration
- **EKS Clusters**: Kubernetes cluster discovery and monitoring
- **RDS Instances**: Database instance tracking
- **S3 Buckets**: Object storage inventory
- **Lambda Functions**: Serverless function catalog
- **EC2 Instances**: Virtual machine inventory
- **EventBridge**: Real-time change notifications

### Azure DevOps Integration
- **Project Sync**: Azure DevOps project tracking
- **Build Pipelines**: CI/CD pipeline definitions
- **Build Runs**: Pipeline execution history
- **Work Items**: User stories, bugs, and tasks

### Snyk Security Integration
- **Project Scanning**: Security vulnerability detection
- **Issue Tracking**: Vulnerability management
- **Test Results**: Scan result aggregation
- **Automated Scanning**: Triggered security scans

## 🎯 Self-Service Actions

### Provision Microservice
Creates a complete microservice with:
- GitHub repository with template code
- CI/CD pipeline configuration
- Kubernetes deployment manifests
- Monitoring and alerting setup
- Database provisioning (optional)

**Approval Required**: Production tier or critical services

### Deploy Service
Deploys services to specified environments with:
- Version selection and validation
- Health check verification
- Rollback capability
- Notification to stakeholders

**Approval Required**: Production deployments

### Create Database
Provisions database instances with:
- Database type selection (PostgreSQL, MySQL, MongoDB, Redis)
- Environment-appropriate sizing
- Backup and encryption configuration
- Network security setup

**Approval Required**: All database creation requests

### Scale Service
Adjusts service capacity with:
- Replica count modification
- Resource limit updates
- Auto-scaling configuration
- Performance monitoring

**Approval Required**: Production scaling beyond thresholds

## 🔐 Security & Compliance

### Security Features
- **Sensitive Data Protection**: All credentials marked as sensitive
- **Audit Logging**: Comprehensive change tracking
- **Encryption**: Sensitive blueprint properties encrypted
- **RBAC**: Role-based access control for all actions

### Compliance Monitoring
- **Standards Support**: SOX, PCI DSS, GDPR, HIPAA, ISO27001
- **Automated Checks**: Regular compliance verification
- **Policy Enforcement**: Configurable compliance policies
- **Reporting**: Automated compliance reports

### Vulnerability Management
- **Continuous Scanning**: Automated security scans
- **Vulnerability Tracking**: Centralized vulnerability database
- **Remediation Workflows**: Automated fix suggestions
- **Risk Assessment**: Priority-based vulnerability scoring

## 📊 DORA Metrics

Automated tracking of DevOps Research and Assessment metrics:

### Deployment Frequency
- Tracks deployments per service and environment
- Categorizes teams by deployment frequency
- Provides trend analysis and benchmarking

### Lead Time for Changes
- Measures time from commit to production
- Tracks across different service types
- Identifies bottlenecks in delivery pipeline

### Change Failure Rate
- Correlates deployments with incidents
- Tracks rollback frequency
- Provides service reliability metrics

### Mean Time to Recovery
- Measures incident response times
- Tracks recovery patterns
- Identifies improvement opportunities

## 🔧 Drift Detection

Automated configuration drift detection with:

### Scheduled Scans
- **Weekly Full Scans**: Comprehensive configuration review
- **Daily Incremental**: Change detection and validation
- **Compliance Checks**: Policy adherence verification

### Remediation
- **Auto-fix**: Low-risk drift automatic correction
- **Manual Review**: High-risk changes require approval
- **Baseline Management**: Configuration baseline tracking

### Monitoring
- **Alert Generation**: Immediate drift notifications
- **Trend Analysis**: Configuration stability metrics
- **Compliance Reporting**: Drift impact on compliance

## 📖 Usage Examples

### Creating a New Microservice

1. **Navigate to Port.io**
2. **Select "Provision Microservice" action**
3. **Fill in service details**:
   - Service name: `user-authentication`
   - Language: `python`
   - Framework: `fastapi`
   - Owner: `alice@company.com`
   - Team: `platform`
4. **Submit for approval** (if production tier)
5. **Track progress** in action runs

### Deploying a Service

1. **Navigate to microservice entity**
2. **Click "Deploy Service" action**
3. **Select parameters**:
   - Environment: `production`
   - Version: `v1.2.3`
   - Force deploy: `false`
4. **Submit for approval**
5. **Monitor deployment progress**

### Running Security Scan

1. **Select microservice or repository**
2. **Click "Run Snyk Security Scan"**
3. **Configure scan options**:
   - Scan types: `dependencies`, `code`
   - Severity threshold: `medium`
4. **Execute scan**
5. **Review results** in vulnerability entities

## 🔄 CI/CD Integration

### GitHub Actions Workflows

The repository includes GitHub Actions workflows for:

- **Deployment**: Automated OpenTofu deployments
- **Drift Detection**: Scheduled configuration scans
- **Security Scanning**: Vulnerability assessments
- **Service Provisioning**: Microservice creation
- **Database Creation**: Database instance provisioning

### Pipeline Integration

Connect with your CI/CD pipelines:

```yaml
# Example GitHub Action for Port updates
- name: Update Port Entity
  uses: port-labs/port-github-action@v1
  with:
    clientId: ${{ secrets.PORT_CLIENT_ID }}
    clientSecret: ${{ secrets.PORT_CLIENT_SECRET }}
    operation: PATCH_RUN
    runId: ${{ github.run_id }}
    status: "SUCCESS"
```

## 📈 Monitoring & Alerting

### Built-in Monitoring
- **Integration Health**: Sync status and error tracking
- **Action Performance**: Execution time and success rates
- **Drift Detection**: Configuration change monitoring
- **Compliance Status**: Policy adherence tracking

### Alert Configuration
Configure alerts for:
- Failed integrations
- High-severity security vulnerabilities
- Compliance violations
- Configuration drift
- Action failures

## 🛠️ Customization

### Adding Custom Blueprints

1. **Create blueprint file** in `blueprints/`
2. **Define properties and relations**
3. **Add to outputs** in `blueprints/outputs.tofu`
4. **Update main module** reference

### Custom Integrations

1. **Create integration file** in `integrations/`
2. **Configure resource mappings**
3. **Add required variables**
4. **Update main module** to include integration

### Custom Actions

1. **Define action** in `actions/`
2. **Configure invocation method**
3. **Set approval requirements**
4. **Add role-based access control**

## 🐛 Troubleshooting

### Common Issues

#### Integration Sync Failures
```bash
# Check integration status
tofu state show module.github_integration.port_integration.github

# Verify credentials
tofu plan -target=module.github_integration
```

#### Blueprint Creation Errors
```bash
# Validate blueprint syntax
tofu validate

# Check for duplicate identifiers
grep -r "identifier.*=" blueprints/
```

#### Action Execution Failures
- Verify webhook URLs are accessible
- Check GitHub Actions repository permissions
- Validate input parameters and schemas

### Debug Mode

Enable debug logging:
```bash
export TF_LOG=DEBUG
tofu apply
```

### State Management

For team environments, use remote state:
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state"
    key    = "port-infrastructure/terraform.tfstate"
    region = "us-west-2"
  }
}
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/new-integration`
3. **Make changes** and test thoroughly
4. **Submit pull request** with detailed description
5. **Ensure CI passes** and get approval

### Development Guidelines

- Follow OpenTofu best practices
- Use consistent naming conventions
- Include comprehensive documentation
- Add appropriate security measures
- Test with multiple environments

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: See `/docs` directory for detailed guides
- **Issues**: Open GitHub issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Port.io Support**: Contact Port.io support for platform issues

## 🙏 Acknowledgments

- Port.io team for the excellent platform
- OpenTofu community for the infrastructure tool
- Contributors and maintainers of this configuration

---

**⚠️ Important Notes:**

- **Secrets Management**: Never commit sensitive values to version control
- **Environment Separation**: Use separate configurations for different environments
- **Backup Strategy**: Regularly backup your Port.io configuration
- **Access Control**: Implement proper RBAC for production environments
- **Monitoring**: Set up comprehensive monitoring and alerting

For detailed setup instructions, see [docs/SETUP.md](docs/SETUP.md).
