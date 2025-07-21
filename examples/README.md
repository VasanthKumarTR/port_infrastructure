# Environment-Specific Configuration Examples

This directory contains environment-specific Terraform variable files that are used by the GitHub Actions workflows.

## Files

- `terraform.tfvars.staging` - Staging environment configuration
- `terraform.tfvars.prod` - Production environment configuration

## Usage

These files are automatically used by the GitHub Actions workflow based on the environment selected:

1. **Staging (default)**: Uses `terraform.tfvars.staging`
2. **Production**: Uses `terraform.tfvars.prod`

## Security Notes

⚠️ **Important**: These files should **NOT** contain sensitive values like:
- API keys
- Passwords
- Private keys
- Access tokens

All sensitive values should be provided via GitHub repository secrets and accessed through environment variables in the workflows.

## Configuration Values

The files contain non-sensitive configuration such as:
- Environment names
- Team email addresses  
- Webhook URLs
- Schedule configurations
- Team lists
- AWS regions (non-sensitive)

## Local Development

For local development, copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your local values. The `terraform.tfvars` file is ignored by git to prevent accidental commits of sensitive data.
