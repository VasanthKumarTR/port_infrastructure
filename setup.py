#!/usr/bin/env python3

"""
Port.io Infrastructure Setup Script (Python Version)
This script helps gather all required credentials and configurations
to deploy and interact with Port.io programmatically using Python.
"""

import os
import sys
import json
import subprocess
import requests
import re
from datetime import datetime
from typing import Dict, List, Optional, Tuple
from pathlib import Path

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

class PortSetup:
    def __init__(self):
        self.config = {}
        self.config_file = "terraform.tfvars"
        self.backup_file = f"terraform.tfvars.backup.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
    def print_header(self, text: str):
        print(f"\n{Colors.BLUE}{'='*50}{Colors.NC}")
        print(f"{Colors.BLUE}{text}{Colors.NC}")
        print(f"{Colors.BLUE}{'='*50}{Colors.NC}\n")
        
    def print_success(self, text: str):
        print(f"{Colors.GREEN}✅ {text}{Colors.NC}")
        
    def print_warning(self, text: str):
        print(f"{Colors.YELLOW}⚠️  {text}{Colors.NC}")
        
    def print_error(self, text: str):
        print(f"{Colors.RED}❌ {text}{Colors.NC}")
        
    def print_info(self, text: str):
        print(f"{Colors.BLUE}ℹ️  {text}{Colors.NC}")
    
    def load_existing_config(self) -> bool:
        """Load existing configuration from terraform.tfvars."""
        if not Path(self.config_file).exists():
            return False
            
        try:
            with open(self.config_file, 'r') as f:
                content = f.read()
                
            # Parse existing configuration
            for line in content.split('\n'):
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip().strip('"')
                    self.config[key] = value
                    
            return True
        except Exception as e:
            self.print_warning(f"Could not load existing config: {e}")
            return False
    
    def show_config_menu(self):
        """Show interactive configuration menu."""
        self.print_header("Configuration Menu")
        
        print("Select what you want to configure/update:")
        print("")
        print("1) Port.io credentials (Required)")
        print("2) Environment settings")
        print("3) AWS integration")
        print("4) GitHub integration")
        print("5) Azure integration")
        print("6) Azure DevOps integration")
        print("7) Snyk integration")
        print("8) Team configuration")
        print("9) Configure all missing components")
        print("0) Continue with current configuration")
        print("")
    
    def check_existing_config(self) -> bool:
        """Check what's already configured."""
        if not Path(self.config_file).exists():
            return False
            
        self.print_header("Checking Existing Configuration")
        
        # Check each component
        if self.config.get('port_client_id') and self.config.get('port_client_secret'):
            self.print_success("Port.io credentials found")
        
        if self.config.get('aws_access_key_id'):
            self.print_success("AWS credentials found")
            
        if self.config.get('github_app_id'):
            self.print_success("GitHub configuration found")
            
        if self.config.get('azure_client_id'):
            self.print_success("Azure credentials found")
            
        if self.config.get('azdo_organization_url'):
            self.print_success("Azure DevOps credentials found")
            
        if self.config.get('snyk_token'):
            self.print_success("Snyk credentials found")
        
        print("")
        return True
    
    def interactive_config(self):
        """Interactive configuration selection."""
        while True:
            self.show_config_menu()
            choice = input("Enter your choice (0-9): ").strip()
            
            if choice == '1':
                self.print_info("Configuring Port.io credentials...")
                self.gather_port_config()
            elif choice == '2':
                self.print_info("Configuring environment settings...")
                self.gather_environment_config()
            elif choice == '3':
                self.print_info("Configuring AWS integration...")
                self.gather_aws_config()
            elif choice == '4':
                self.print_info("Configuring GitHub integration...")
                self.gather_github_config()
            elif choice == '5':
                self.print_info("Configuring Azure integration...")
                self.gather_azure_config()
            elif choice == '6':
                self.print_info("Configuring Azure DevOps integration...")
                optional_config = self.gather_optional_configs()
                if 'azdo_organization_url' in optional_config:
                    self.config.update(optional_config)
            elif choice == '7':
                self.print_info("Configuring Snyk integration...")
                optional_config = self.gather_optional_configs()
                if 'snyk_token' in optional_config:
                    self.config.update(optional_config)
            elif choice == '8':
                self.print_info("Configuring team settings...")
                # Team config is handled in write_config_file
                pass
            elif choice == '9':
                self.print_info("Configuring all missing components...")
                self.configure_missing_components()
                break
            elif choice == '0':
                self.print_info("Continuing with current configuration...")
                break
            else:
                self.print_warning("Please enter a number between 0-9")
                continue
            
            print("")
            continue_config = input("Configure another component? (y/n): ").strip().lower()
            if not continue_config.startswith('y'):
                break
    
    def configure_missing_components(self):
        """Configure only missing required components."""
        # Check required components
        if not self.config.get('port_client_id') or not self.config.get('port_client_secret'):
            self.print_info("Port.io credentials missing - configuring...")
            self.gather_port_config()
        
        if not self.config.get('environment') or not self.config.get('team_email'):
            self.print_info("Environment settings missing - configuring...")
            self.gather_environment_config()
        
        # Ask about optional components
        if not self.config.get('aws_access_key_id'):
            config_aws = input("AWS integration not configured. Configure now? (y/n): ").strip().lower()
            if config_aws.startswith('y'):
                self.gather_aws_config()
        
        if not self.config.get('github_app_id'):
            config_github = input("GitHub integration not configured. Configure now? (y/n): ").strip().lower()
            if config_github.startswith('y'):
                self.gather_github_config()
        
        if not self.config.get('azure_client_id'):
            config_azure = input("Azure integration not configured. Configure now? (y/n): ").strip().lower()
            if config_azure.startswith('y'):
                self.gather_azure_config()
        
        optional_config = self.gather_optional_configs()
        self.config.update(optional_config)
        
    def validate_dependencies(self) -> bool:
        """Validate that required tools are installed."""
        self.print_header("Validating Dependencies")
        
        required_tools = ['tofu', 'curl', 'git']
        missing_tools = []
        
        for tool in required_tools:
            try:
                subprocess.run([tool, '--version'], 
                             capture_output=True, check=True)
            except (subprocess.CalledProcessError, FileNotFoundError):
                missing_tools.append(tool)
        
        if not missing_tools:
            self.print_success("All required tools are installed")
            return True
        else:
            self.print_error(f"Missing required tools: {', '.join(missing_tools)}")
            print("Please install the missing tools and run this script again.")
            return False
    
    def validate_email(self, email: str) -> bool:
        """Validate email format."""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return re.match(pattern, email) is not None
    
    def test_port_credentials(self, client_id: str, client_secret: str) -> bool:
        """Test Port.io credentials by getting an access token."""
        try:
            self.print_info("Testing Port.io credentials...")
            
            response = requests.post(
                "https://api.getport.io/v1/auth/access_token",
                json={
                    "clientId": client_id,
                    "clientSecret": client_secret
                },
                timeout=10
            )
            
            if response.status_code == 200 and 'accessToken' in response.json():
                self.print_success("Port.io credentials are valid")
                return True
            else:
                self.print_error(f"Invalid Port.io credentials: {response.text}")
                return False
                
        except requests.RequestException as e:
            self.print_error(f"Failed to test Port.io credentials: {e}")
            return False
    
    def test_aws_credentials(self, access_key: str, secret_key: str, region: str) -> bool:
        """Test AWS credentials using AWS CLI."""
        try:
            self.print_info("Testing AWS credentials...")
            
            env = os.environ.copy()
            env.update({
                'AWS_ACCESS_KEY_ID': access_key,
                'AWS_SECRET_ACCESS_KEY': secret_key,
                'AWS_DEFAULT_REGION': region
            })
            
            result = subprocess.run(
                ['aws', 'sts', 'get-caller-identity'],
                env=env,
                capture_output=True,
                timeout=10
            )
            
            if result.returncode == 0:
                self.print_success("AWS credentials are valid")
                return True
            else:
                self.print_error("Invalid AWS credentials")
                return False
                
        except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
            self.print_warning("AWS CLI not found or timeout, skipping credential validation")
            return True
    
    def gather_port_config(self) -> Dict[str, str]:
        """Gather Port.io configuration."""
        self.print_header("Port.io Configuration")
        
        # Show existing configuration
        if self.config.get('port_client_id') and self.config.get('port_client_secret'):
            print(f"Current Client ID: {self.config['port_client_id']}")
            keep_existing = input("Keep current Port.io credentials? (y/n): ").strip().lower()
            if keep_existing.startswith('y'):
                self.print_success("Using existing Port.io credentials")
                return {
                    'port_client_id': self.config['port_client_id'],
                    'port_client_secret': self.config['port_client_secret'],
                    'port_base_url': 'https://api.getport.io'
                }
        
        print("To get your Port.io credentials:")
        print("1. Go to https://app.getport.io")
        print("2. Navigate to Settings > Developers")
        print("3. Create or use existing API credentials")
        print("")
        
        while True:
            client_id = input("Enter your Port.io Client ID: ").strip()
            client_secret = input("Enter your Port.io Client Secret: ").strip()
            
            if self.test_port_credentials(client_id, client_secret):
                result = {
                    'port_client_id': client_id,
                    'port_client_secret': client_secret,
                    'port_base_url': 'https://api.getport.io'
                }
                self.config.update(result)
                return result
            else:
                self.print_warning("Please check your credentials and try again")
    
    def gather_environment_config(self) -> Dict[str, str]:
        """Gather environment configuration."""
        self.print_header("Environment Configuration")
        
        # Show existing configuration
        if self.config.get('environment') and self.config.get('team_email'):
            print(f"Current Environment: {self.config['environment']}")
            print(f"Current Team Email: {self.config['team_email']}")
            keep_existing = input("Keep current environment settings? (y/n): ").strip().lower()
            if keep_existing.startswith('y'):
                self.print_success("Using existing environment configuration")
                return {
                    'environment': self.config['environment'],
                    'team_email': self.config['team_email']
                }
        
        print("Select your deployment environment:")
        print("1) Development")
        print("2) Staging")
        print("3) Production")
        
        env_map = {'1': 'dev', '2': 'staging', '3': 'prod'}
        
        while True:
            choice = input("Enter your choice (1-3): ").strip()
            if choice in env_map:
                environment = env_map[choice]
                break
            else:
                self.print_warning("Please enter 1, 2, or 3")
        
        while True:
            team_email = input("Enter your team email address: ").strip()
            if self.validate_email(team_email):
                break
            else:
                self.print_warning("Please enter a valid email address")
        
        result = {
            'environment': environment,
            'team_email': team_email
        }
        self.config.update(result)
        return result
    
    def gather_aws_config(self) -> Dict[str, str]:
        """Gather AWS configuration."""
        self.print_header("AWS Configuration")
        
        # Show existing configuration
        if self.config.get('aws_access_key_id'):
            print("Current AWS configuration found")
            print(f"Access Key ID: {self.config['aws_access_key_id'][:8]}...")
            print(f"Region: {self.config.get('aws_region', 'us-west-2')}")
            keep_existing = input("Keep current AWS configuration? (y/n): ").strip().lower()
            if keep_existing.startswith('y'):
                self.print_success("Using existing AWS configuration")
                return {
                    'aws_access_key_id': self.config['aws_access_key_id'],
                    'aws_secret_access_key': self.config['aws_secret_access_key'],
                    'aws_region': self.config.get('aws_region', 'us-west-2')
                }
        
        configure = input("Do you want to configure AWS integration? (y/n): ").strip().lower()
        
        if configure.startswith('y'):
            print("\nTo get AWS credentials:")
            print("1. Go to AWS IAM Console")
            print("2. Create or use existing IAM user with appropriate permissions")
            print("3. Generate access keys")
            print("")
            
            while True:
                access_key = input("Enter AWS Access Key ID: ").strip()
                secret_key = input("Enter AWS Secret Access Key: ").strip()
                region = input("Enter AWS Region (default: us-west-2): ").strip() or "us-west-2"
                
                if self.test_aws_credentials(access_key, secret_key, region):
                    result = {
                        'aws_access_key_id': access_key,
                        'aws_secret_access_key': secret_key,
                        'aws_region': region
                    }
                    self.config.update(result)
                    return result
                else:
                    self.print_warning("Please check your AWS credentials and try again")
        
        return {}
    
    def gather_github_config(self) -> Dict[str, str]:
        """Gather GitHub configuration."""
        self.print_header("GitHub Configuration")
        
        # Show existing configuration
        if self.config.get('github_app_id'):
            print("Current GitHub configuration found")
            print(f"App ID: {self.config['github_app_id']}")
            print(f"Installation ID: {self.config.get('github_installation_id', 'N/A')}")
            print(f"Organization: {self.config.get('github_organization', 'N/A')}")
            keep_existing = input("Keep current GitHub configuration? (y/n): ").strip().lower()
            if keep_existing.startswith('y'):
                self.print_success("Using existing GitHub configuration")
                return {
                    'github_app_id': self.config['github_app_id'],
                    'github_installation_id': self.config['github_installation_id'],
                    'github_private_key': self.config['github_private_key'],
                    'github_organization': self.config['github_organization'],
                    'github_actions_repo': self.config.get('github_actions_repo', 'port-infrastructure'),
                    'github_actions_webhook_url': f"https://api.github.com/repos/{self.config['github_organization']}/{self.config.get('github_actions_repo', 'port-infrastructure')}/dispatches"
                }
        
        configure = input("Do you want to configure GitHub integration? (y/n): ").strip().lower()
        
        if configure.startswith('y'):
            print("\nTo create a GitHub App:")
            print("1. Go to GitHub Settings > Developer settings > GitHub Apps")
            print("2. Click 'New GitHub App'")
            print("3. Configure with repository read permissions")
            print("4. Install the app in your organization")
            print("")
            
            app_id = input("Enter GitHub App ID: ").strip()
            installation_id = input("Enter GitHub Installation ID: ").strip()
            
            print("Enter GitHub App Private Key (paste the entire key, then press Enter twice):")
            private_key_lines = []
            while True:
                line = input()
                if line.strip() == "":
                    break
                private_key_lines.append(line)
            
            private_key = "\n".join(private_key_lines)
            
            organization = input("Enter GitHub Organization: ").strip()
            repo = input("Enter GitHub Actions Repository (default: port-infrastructure): ").strip()
            repo = repo or "port-infrastructure"
            
            result = {
                'github_app_id': app_id,
                'github_installation_id': installation_id,
                'github_private_key': private_key,
                'github_organization': organization,
                'github_actions_repo': repo,
                'github_actions_webhook_url': f"https://api.github.com/repos/{organization}/{repo}/dispatches"
            }
            self.config.update(result)
            return result
        
        return {}
    
    def gather_azure_config(self) -> Dict[str, str]:
        """Gather Azure configuration."""
        self.print_header("Azure Configuration")
        
        configure = input("Do you want to configure Azure integration? (y/n): ").strip().lower()
        
        if configure.startswith('y'):
            print("\nTo get Azure credentials:")
            print("1. Go to Azure Active Directory > App registrations")
            print("2. Create new registration or use existing")
            print("3. Note the Application (client) ID and Directory (tenant) ID")
            print("4. Create a client secret")
            print("")
            
            client_id = input("Enter Azure Client ID: ").strip()
            client_secret = input("Enter Azure Client Secret: ").strip()
            tenant_id = input("Enter Azure Tenant ID: ").strip()
            subscription_id = input("Enter Azure Subscription ID: ").strip()
            
            return {
                'azure_client_id': client_id,
                'azure_client_secret': client_secret,
                'azure_tenant_id': tenant_id,
                'azure_subscription_id': subscription_id
            }
        
        return {}
    
    def gather_optional_configs(self) -> Dict[str, str]:
        """Gather optional service configurations."""
        config = {}
        
        # Azure DevOps
        self.print_header("Azure DevOps Configuration")
        configure_azdo = input("Do you want to configure Azure DevOps integration? (y/n): ").strip().lower()
        
        if configure_azdo.startswith('y'):
            config['azdo_organization_url'] = input("Enter Azure DevOps Organization URL: ").strip()
            config['azdo_personal_token'] = input("Enter Azure DevOps Personal Access Token: ").strip()
        
        # Snyk
        self.print_header("Snyk Configuration")
        configure_snyk = input("Do you want to configure Snyk integration? (y/n): ").strip().lower()
        
        if configure_snyk.startswith('y'):
            config['snyk_token'] = input("Enter Snyk API Token: ").strip()
            config['snyk_organization'] = input("Enter Snyk Organization ID: ").strip()
        
        return config
    
    def gather_team_config(self) -> Tuple[List[str], List[str]]:
        """Gather team and approval configuration."""
        self.print_header("Team Configuration")
        
        print("Configure your teams (enter team names, one per line, empty line to finish):")
        teams = []
        while True:
            team = input("Team name: ").strip()
            if not team:
                break
            teams.append(team)
        
        if not teams:
            teams = ["platform", "backend", "frontend", "mobile", "data"]
            self.print_info("Using default teams: " + ", ".join(teams))
        
        print("\nConfigure approval recipients (enter email addresses, one per line, empty line to finish):")
        recipients = []
        while True:
            email = input("Email address: ").strip()
            if not email:
                break
            if self.validate_email(email):
                recipients.append(email)
            else:
                self.print_warning("Invalid email format, skipping")
        
        if not recipients:
            recipients = [self.config['team_email']]
            self.print_info("Using team email as default approval recipient")
        
        return teams, recipients
    
    def write_config_file(self):
        """Write the configuration to terraform.tfvars file."""
        self.print_header("Writing Configuration")
        
        # Backup existing file
        if Path(self.config_file).exists():
            Path(self.config_file).rename(self.backup_file)
            self.print_info(f"Backed up existing configuration to {self.backup_file}")
        
        teams, recipients = self.gather_team_config()
        
        with open(self.config_file, 'w') as f:
            f.write(f"# Port.io Infrastructure Configuration\n")
            f.write(f"# Generated by Python setup script on {datetime.now()}\n\n")
            
            # Core configuration
            f.write("# Port.io Configuration (Required)\n")
            f.write(f'port_client_id     = "{self.config["port_client_id"]}"\n')
            f.write(f'port_client_secret = "{self.config["port_client_secret"]}"\n')
            f.write(f'port_base_url      = "{self.config["port_base_url"]}"\n\n')
            
            f.write("# Environment Configuration\n")
            f.write(f'environment = "{self.config["environment"]}"\n')
            f.write(f'team_email  = "{self.config["team_email"]}"\n\n')
            
            # AWS configuration
            if 'aws_access_key_id' in self.config:
                f.write("# AWS Configuration\n")
                f.write(f'aws_access_key_id     = "{self.config["aws_access_key_id"]}"\n')
                f.write(f'aws_secret_access_key = "{self.config["aws_secret_access_key"]}"\n')
                f.write(f'aws_region           = "{self.config["aws_region"]}"\n\n')
            
            # Azure configuration
            if 'azure_client_id' in self.config:
                f.write("# Azure Configuration\n")
                f.write(f'azure_client_id       = "{self.config["azure_client_id"]}"\n')
                f.write(f'azure_client_secret   = "{self.config["azure_client_secret"]}"\n')
                f.write(f'azure_tenant_id       = "{self.config["azure_tenant_id"]}"\n')
                f.write(f'azure_subscription_id = "{self.config["azure_subscription_id"]}"\n\n')
            
            # GitHub configuration
            if 'github_app_id' in self.config:
                f.write("# GitHub Configuration\n")
                f.write(f'github_app_id          = "{self.config["github_app_id"]}"\n')
                f.write(f'github_private_key     = <<-EOF\n')
                f.write(f'{self.config["github_private_key"]}\n')
                f.write(f'EOF\n')
                f.write(f'github_installation_id = "{self.config["github_installation_id"]}"\n')
                f.write(f'github_actions_webhook_url = "{self.config["github_actions_webhook_url"]}"\n\n')
            
            # Optional configurations
            if 'azdo_organization_url' in self.config:
                f.write("# Azure DevOps Configuration\n")
                f.write(f'azdo_organization_url = "{self.config["azdo_organization_url"]}"\n')
                f.write(f'azdo_personal_token   = "{self.config["azdo_personal_token"]}"\n\n')
            
            if 'snyk_token' in self.config:
                f.write("# Snyk Configuration\n")
                f.write(f'snyk_token        = "{self.config["snyk_token"]}"\n')
                f.write(f'snyk_organization = "{self.config["snyk_organization"]}"\n\n')
            
            # Team and approval configuration
            f.write("# Optional Configuration\n")
            f.write("enable_audit_logging     = true\n")
            f.write('drift_detection_schedule = "0 2 * * 1"  # Weekly on Monday at 2 AM\n')
            f.write('sync_schedule           = "0 1 * * *"   # Daily at 1 AM\n\n')
            
            f.write("# Team Configuration\n")
            f.write("available_teams = [\n")
            for team in teams:
                f.write(f'  "{team}",\n')
            f.write("]\n\n")
            
            f.write("approval_recipients = [\n")
            for recipient in recipients:
                f.write(f'  "{recipient}",\n')
            f.write("]\n\n")
            
            f.write(f'github_organization = "{self.config.get("github_organization", "")}"\n')
            f.write(f'github_actions_repo = "{self.config.get("github_actions_repo", "")}"\n\n')
            
            f.write("# Webhook URLs for actions (update these with your actual endpoints)\n")
            f.write('dora_webhook_url            = "https://your-dora-metrics-service.com/webhook"\n')
            f.write('dora_collection_webhook_url = "https://your-dora-collector.com/webhook"\n')
            f.write('port_webhook_url           = "https://your-port-webhook-handler.com/webhook"\n')
        
        self.print_success(f"Configuration written to {self.config_file}")
    
    def create_port_api_client(self):
        """Create a Python Port.io API client."""
        client_code = '''#!/usr/bin/env python3

"""
Port.io API Client
Simple Python client for interacting with Port.io API
"""

import os
import json
import requests
from typing import Dict, List, Optional

class PortClient:
    def __init__(self, client_id: str = None, client_secret: str = None):
        self.client_id = client_id or os.getenv('PORT_CLIENT_ID')
        self.client_secret = client_secret or os.getenv('PORT_CLIENT_SECRET')
        self.base_url = "https://api.getport.io/v1"
        self.access_token = None
    
    def get_access_token(self) -> str:
        """Get access token from Port.io."""
        if self.access_token:
            return self.access_token
            
        response = requests.post(
            f"{self.base_url}/auth/access_token",
            json={
                "clientId": self.client_id,
                "clientSecret": self.client_secret
            }
        )
        response.raise_for_status()
        
        self.access_token = response.json()["accessToken"]
        return self.access_token
    
    def make_request(self, method: str, endpoint: str, **kwargs) -> Dict:
        """Make authenticated request to Port.io API."""
        token = self.get_access_token()
        headers = kwargs.pop('headers', {})
        headers['Authorization'] = f'Bearer {token}'
        
        response = requests.request(
            method, 
            f"{self.base_url}/{endpoint.lstrip('/')}", 
            headers=headers,
            **kwargs
        )
        response.raise_for_status()
        return response.json()
    
    def get_blueprints(self) -> List[Dict]:
        """Get all blueprints."""
        return self.make_request('GET', '/blueprints')['blueprints']
    
    def get_entities(self, blueprint: str) -> List[Dict]:
        """Get entities for a blueprint."""
        return self.make_request('GET', f'/blueprints/{blueprint}/entities')['entities']
    
    def get_integrations(self) -> List[Dict]:
        """Get all integrations."""
        return self.make_request('GET', '/integrations')
    
    def create_entity(self, blueprint: str, entity_data: Dict) -> Dict:
        """Create a new entity."""
        return self.make_request('POST', f'/blueprints/{blueprint}/entities', json=entity_data)
    
    def update_entity(self, blueprint: str, entity_id: str, entity_data: Dict) -> Dict:
        """Update an existing entity."""
        return self.make_request('PUT', f'/blueprints/{blueprint}/entities/{entity_id}', json=entity_data)

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Port.io API Client')
    parser.add_argument('command', choices=['blueprints', 'entities', 'integrations'])
    parser.add_argument('--blueprint', help='Blueprint name for entities command')
    args = parser.parse_args()
    
    # Load credentials from terraform.tfvars if available
    try:
        with open('terraform.tfvars', 'r') as f:
            for line in f:
                if line.startswith('port_client_id'):
                    client_id = line.split('=')[1].strip().strip('"')
                elif line.startswith('port_client_secret'):
                    client_secret = line.split('=')[1].strip().strip('"')
    except FileNotFoundError:
        print("terraform.tfvars not found, using environment variables")
        client_id = os.getenv('PORT_CLIENT_ID')
        client_secret = os.getenv('PORT_CLIENT_SECRET')
    
    client = PortClient(client_id, client_secret)
    
    try:
        if args.command == 'blueprints':
            blueprints = client.get_blueprints()
            print(json.dumps(blueprints, indent=2))
        elif args.command == 'entities':
            if not args.blueprint:
                print("--blueprint required for entities command")
                sys.exit(1)
            entities = client.get_entities(args.blueprint)
            print(json.dumps(entities, indent=2))
        elif args.command == 'integrations':
            integrations = client.get_integrations()
            print(json.dumps(integrations, indent=2))
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
'''
        
        with open('port_client.py', 'w') as f:
            f.write(client_code)
        
        os.chmod('port_client.py', 0o755)
        self.print_success("Created port_client.py API client")
    
    def run_tofu_commands(self):
        """Run OpenTofu initialization and validation."""
        self.print_header("Initializing OpenTofu")
        
        try:
            # Initialize
            subprocess.run(['tofu', 'init'], check=True)
            self.print_success("OpenTofu initialized successfully")
            
            # Validate
            subprocess.run(['tofu', 'validate'], check=True)
            self.print_success("Configuration is valid")
            
            # Plan
            self.print_info("Creating deployment plan...")
            subprocess.run(['tofu', 'plan', '-out=tfplan'], check=True)
            self.print_success("Planning completed successfully")
            
            # Ask about deployment
            deploy = input("Do you want to deploy the infrastructure now? (y/n): ").strip().lower()
            
            if deploy.startswith('y'):
                subprocess.run(['tofu', 'apply', 'tfplan'], check=True)
                self.print_success("Infrastructure deployed successfully!")
                self.print_info("Check your Port.io organization to see the new configuration")
            else:
                self.print_info("Deployment skipped. You can deploy later with: tofu apply tfplan")
                
        except subprocess.CalledProcessError as e:
            self.print_error(f"OpenTofu command failed: {e}")
            return False
        
        return True
    
    def run(self):
        """Main execution flow."""
        print(f"{Colors.GREEN}")
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║                 Port.io Infrastructure Setup                ║")
        print("║                      (Python Version)                       ║")
        print("║                                                              ║")
        print("║  This script will help you configure and deploy your        ║")
        print("║  Port.io software catalog infrastructure using OpenTofu     ║")
        print("╚══════════════════════════════════════════════════════════════╝")
        print(f"{Colors.NC}\n")
        
        if not self.validate_dependencies():
            sys.exit(1)
        
        # Load existing configuration if available
        config_exists = self.load_existing_config()
        
        if config_exists and self.check_existing_config():
            print("")
            mode = input("Configuration file found. Do you want to update specific components or start fresh? (update/fresh): ").strip().lower()
            
            if mode.startswith('f'):
                self.print_warning("Starting fresh configuration (existing config will be backed up)")
                self.config = {}  # Clear existing config
                # Gather all configurations fresh
                self.config.update(self.gather_port_config())
                self.config.update(self.gather_environment_config())
                self.configure_missing_components()
            else:
                self.print_info("Using update mode")
                self.interactive_config()
        else:
            self.print_info("No existing configuration found. Starting initial setup...")
            self.config.update(self.gather_port_config())
            self.config.update(self.gather_environment_config())
            self.configure_missing_components()
        
        # Ensure we have required components
        if not self.config.get('port_client_id') or not self.config.get('port_client_secret'):
            self.print_error("Port.io credentials are required!")
            self.config.update(self.gather_port_config())
        
        if not self.config.get('environment') or not self.config.get('team_email'):
            self.print_error("Environment settings are required!")
            self.config.update(self.gather_environment_config())
        
        # Write configuration and create utilities
        self.write_config_file()
        self.create_port_api_client()
        
        # Ask about OpenTofu commands
        run_tofu = input("Do you want to run OpenTofu initialization and validation now? (y/n): ").strip().lower()
        if run_tofu.startswith('y'):
            self.run_tofu_commands()
        else:
            self.print_info("Skipping OpenTofu commands. You can run them later with:")
            print("  tofu init && tofu plan && tofu apply")
        
        self.print_header("Setup Complete!")
        print("Next steps:")
        print("1. Review the generated terraform.tfvars file")
        print("2. Use 'python3 port_client.py' to interact with Port.io API")
        print("3. Run './validate.sh' to validate your configuration")
        print("4. Run 'tofu plan && tofu apply' to deploy infrastructure")
        print("")
        self.print_success("Port.io infrastructure setup is ready!")

if __name__ == "__main__":
    setup = PortSetup()
    setup.run()
