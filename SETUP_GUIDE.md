# Port.io Infrastructure Setup Guide

This guide will walk you through setting up and deploying your Port.io software catalog infrastructure using OpenTofu.

## Prerequisites

Before running the setup scripts, ensure you have the following tools installed:

### Required Tools

1. **OpenTofu** (v1.6+)
   ```bash
   # macOS with Homebrew
   brew install opentofu
   
   # Or download from https://opentofu.org/docs/intro/install/
   ```

2. **curl** (usually pre-installed on macOS/Linux)

3. **git** (usually pre-installed on macOS/Linux)

4. **jq** (for JSON processing in bash script)
   ```bash
   # macOS with Homebrew
   brew install jq
   ```

### Optional Tools

5. **AWS CLI** (for AWS credential validation)
   ```bash
   # macOS with Homebrew
   brew install awscli
   ```

6. **Python 3.8+** (for Python setup script)
   ```bash
   # macOS usually has Python pre-installed
   python3 --version
   
   # Install dependencies
   pip3 install -r requirements.txt
   ```

## Setup Options

You have two setup script options:

### Option 1: Bash Script (Recommended for Unix/Linux users)

```bash
./setup.sh
```

### Option 2: Python Script (Cross-platform)

```bash
# Install Python dependencies first
pip3 install -r requirements.txt

# Run the setup
python3 setup.py
```

## Step-by-Step Setup Process

Both scripts will guide you through the following configuration steps:

### 1. Port.io Configuration (Required)

You'll need to provide:
- **Client ID**: Get from Port.io Settings > Developers
- **Client Secret**: Get from Port.io Settings > Developers

The script will validate these credentials by testing API access.

### 2. Environment Configuration (Required)

- **Environment**: Choose from Development, Staging, or Production
- **Team Email**: Primary contact email for your team

### 3. Cloud Integrations (Optional)

#### AWS Integration
- **Access Key ID**: IAM user access key
- **Secret Access Key**: IAM user secret key  
- **Region**: AWS region (default: us-west-2)

#### Azure Integration
- **Client ID**: Azure App Registration client ID
- **Client Secret**: Azure App Registration secret
- **Tenant ID**: Azure AD tenant ID
- **Subscription ID**: Azure subscription ID

### 4. GitHub Integration (Optional)

You'll need to create a GitHub App:

1. Go to GitHub Settings > Developer settings > GitHub Apps
2. Click "New GitHub App"
3. Configure with repository read permissions
4. Install the app in your organization
5. Provide:
   - **App ID**: GitHub App ID
   - **Installation ID**: Installation ID after installing the app
   - **Private Key**: GitHub App private key (full PEM content)
   - **Organization**: Your GitHub organization name

### 5. Additional Service Integrations (Optional)

#### Azure DevOps
- **Organization URL**: e.g., https://dev.azure.com/yourorg
- **Personal Access Token**: Azure DevOps PAT

#### Snyk Security Scanning
- **API Token**: Snyk API token
- **Organization ID**: Snyk organization ID

### 6. Team and Approval Configuration

- **Teams**: List of team names for your organization
- **Approval Recipients**: Email addresses for approval workflows

## Generated Files

After running the setup script, you'll have:

1. **`terraform.tfvars`**: Your configuration file with all credentials
2. **`port-cli.sh`**: Simple bash script for Port.io API interactions (bash setup)
3. **`port_client.py`**: Python client for Port.io API interactions (Python setup)
4. **`deploy.sh`**: Deployment script for infrastructure (bash setup)

## Deployment

### Manual Deployment

```bash
# Initialize OpenTofu
tofu init

# Review the plan
tofu plan -out=tfplan

# Apply the infrastructure
tofu apply tfplan
```

### Using Generated Scripts

#### Bash Script Users
```bash
# Deploy infrastructure
./deploy.sh

# Interact with Port.io API
./port-cli.sh blueprints
./port-cli.sh entities microservice
./port-cli.sh integrations
```

#### Python Script Users
```bash
# Deploy infrastructure manually
tofu init && tofu plan -out=tfplan && tofu apply tfplan

# Interact with Port.io API
python3 port_client.py blueprints
python3 port_client.py entities --blueprint microservice
python3 port_client.py integrations
```

## Post-Deployment

After successful deployment:

1. **Visit Port.io**: Go to https://app.getport.io to see your new software catalog
2. **Check Blueprints**: Verify that blueprints (microservice, environment, etc.) are created
3. **Test Integrations**: Ensure cloud integrations are working and discovering resources
4. **Configure Teams**: Set up team permissions and access controls
5. **Test Actions**: Try the self-service actions for provisioning resources

## Troubleshooting

### Common Issues

1. **Invalid Credentials**
   - Double-check all API credentials
   - Ensure permissions are correctly set
   - Test credentials independently

2. **OpenTofu Errors**
   ```bash
   # Reinitialize if needed
   tofu init -upgrade
   
   # Check configuration
   tofu validate
   ```

3. **GitHub App Issues**
   - Verify the app is installed in your organization
   - Check that the private key is complete (including headers/footers)
   - Ensure proper permissions are granted

4. **Network Issues**
   - Check firewall settings
   - Verify internet connectivity
   - Ensure corporate proxies are configured

### Getting Help

1. **Check Logs**: OpenTofu provides detailed error messages
2. **Port.io Documentation**: https://docs.getport.io
3. **OpenTofu Documentation**: https://opentofu.org/docs/

## Security Best Practices

1. **Credential Management**
   - Store `terraform.tfvars` securely
   - Use environment variables for CI/CD
   - Rotate credentials regularly

2. **Access Control**
   - Implement least-privilege access
   - Use separate environments (dev/staging/prod)
   - Regular access reviews

3. **Monitoring**
   - Enable audit logging
   - Monitor drift detection alerts
   - Review approval workflows

## Next Steps

After setup, consider:

1. **Customizing Blueprints**: Modify blueprints to match your architecture
2. **Adding More Integrations**: Connect additional tools and services
3. **Creating Custom Actions**: Build organization-specific automation
4. **Setting Up Monitoring**: Configure drift detection and alerting
5. **Training Teams**: Onboard teams to use the software catalog

## File Structure

```
port_infrastructure/
├── main.tofu                     # Main OpenTofu configuration
├── providers.tofu                # Provider configurations
├── variables.tofu                # Variable definitions
├── outputs.tofu                  # Output definitions
├── terraform.tfvars              # Your configuration (generated)
├── terraform.tfvars.example      # Example configuration
├── setup.sh                      # Bash setup script
├── setup.py                      # Python setup script
├── requirements.txt              # Python dependencies
├── port-cli.sh                   # Port.io CLI helper (generated)
├── port_client.py                # Port.io Python client (generated)
├── deploy.sh                     # Deployment script (generated)
├── blueprints/                   # Blueprint definitions
│   ├── core.tofu
│   ├── security.tofu
│   └── custom.tofu
├── integrations/                 # Integration configurations
│   ├── github.tofu
│   ├── aws.tofu
│   ├── azure_devops.tofu
│   ├── snyk.tofu
│   └── dora.tofu
├── actions/                      # Self-service actions
│   ├── service_actions.tofu
│   └── approval_workflows.tofu
├── utils/                        # Utility modules
│   ├── port_client.tofu
│   └── drift_detection.tofu
└── .github/workflows/            # CI/CD workflows
    ├── deploy.yml
    ├── drift-detection.yml
    └── provision-microservice.yml
```

Choose your preferred setup method and get started! 🚀
