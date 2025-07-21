#!/bin/bash

# Port.io Infrastructure Setup Script - Menu Driven
# Interactive menu system for configuring Port.io credentials and integrations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration variables
CONFIG_FILE="terraform.tfvars"
BACKUP_FILE="terraform.tfvars.backup.$(date +%Y%m%d_%H%M%S)"

# Configuration variables (using simple variables instead of associative array)
port_client_id=""
port_client_secret=""
port_base_url="https://api.getport.io"
environment=""
team_email=""
aws_access_key_id=""
aws_secret_access_key=""
aws_region=""
github_app_id=""
github_installation_id=""
github_organization=""
github_actions_repo=""
github_private_key=""
github_actions_webhook_url=""
azure_client_id=""
azure_client_secret=""
azure_tenant_id=""
azure_subscription_id=""
azdo_organization_url=""
azdo_personal_token=""
snyk_token=""
snyk_organization=""

# Print colored output functions
print_header() {
    echo -e "\n${BLUE}╔$(printf '═%.0s' {1..60})╗${NC}"
    echo -e "${BLUE}║$(printf ' %.0s' {1..60})║${NC}"
    echo -e "${BLUE}║  $1$(printf ' %.0s' $(seq 1 $((58 - ${#1}))))║${NC}"
    echo -e "${BLUE}║$(printf ' %.0s' {1..60})║${NC}"
    echo -e "${BLUE}╚$(printf '═%.0s' {1..60})╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Validate email format
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Load existing configuration
load_existing_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        print_info "Loading existing configuration..."
        
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ $key =~ ^#.*$ || -z $key ]] && continue
            
            # Clean up the key and value
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs | sed 's/^"//' | sed 's/"$//')
            
            # Set the appropriate variable
            case $key in
                port_client_id) port_client_id="$value" ;;
                port_client_secret) port_client_secret="$value" ;;
                port_base_url) port_base_url="$value" ;;
                environment) environment="$value" ;;
                team_email) team_email="$value" ;;
                aws_access_key_id) aws_access_key_id="$value" ;;
                aws_secret_access_key) aws_secret_access_key="$value" ;;
                aws_region) aws_region="$value" ;;
                github_app_id) github_app_id="$value" ;;
                github_installation_id) github_installation_id="$value" ;;
                github_organization) github_organization="$value" ;;
                github_actions_repo) github_actions_repo="$value" ;;
                github_actions_webhook_url) github_actions_webhook_url="$value" ;;
                azure_client_id) azure_client_id="$value" ;;
                azure_client_secret) azure_client_secret="$value" ;;
                azure_tenant_id) azure_tenant_id="$value" ;;
                azure_subscription_id) azure_subscription_id="$value" ;;
                azdo_organization_url) azdo_organization_url="$value" ;;
                azdo_personal_token) azdo_personal_token="$value" ;;
                snyk_token) snyk_token="$value" ;;
                snyk_organization) snyk_organization="$value" ;;
            esac
        done < "$CONFIG_FILE"
        
        print_success "Loaded existing configuration"
        return 0
    else
        print_info "No existing configuration found"
        return 1
    fi
}

# Show current configuration status
show_config_status() {
    print_header "Current Configuration Status"
    
    echo -e "${BLUE}Component Status:${NC}"
    
    # Port.io
    if [[ -n "$port_client_id" && -n "$port_client_secret" ]]; then
        echo -e "  ${GREEN}✅ Port.io Credentials${NC} - Client ID: ${port_client_id:0:8}..."
    else
        echo -e "  ${RED}❌ Port.io Credentials${NC} - Not configured"
    fi
    
    # Environment
    if [[ -n "$environment" && -n "$team_email" ]]; then
        echo -e "  ${GREEN}✅ Environment Settings${NC} - $environment ($team_email)"
    else
        echo -e "  ${RED}❌ Environment Settings${NC} - Not configured"
    fi
    
    # AWS
    if [[ -n "$aws_access_key_id" ]]; then
        echo -e "  ${GREEN}✅ AWS Integration${NC} - Region: ${aws_region:-us-west-2}"
    else
        echo -e "  ${YELLOW}○ AWS Integration${NC} - Optional (not configured)"
    fi
    
    # GitHub
    if [[ -n "$github_app_id" ]]; then
        echo -e "  ${GREEN}✅ GitHub Integration${NC} - App ID: $github_app_id"
    else
        echo -e "  ${YELLOW}○ GitHub Integration${NC} - Optional (not configured)"
    fi
    
    # Azure
    if [[ -n "$azure_client_id" ]]; then
        echo -e "  ${GREEN}✅ Azure Integration${NC} - Tenant: ${azure_tenant_id:0:8}..."
    else
        echo -e "  ${YELLOW}○ Azure Integration${NC} - Optional (not configured)"
    fi
    
    # Azure DevOps
    if [[ -n "$azdo_organization_url" ]]; then
        echo -e "  ${GREEN}✅ Azure DevOps${NC} - $azdo_organization_url"
    else
        echo -e "  ${YELLOW}○ Azure DevOps${NC} - Optional (not configured)"
    fi
    
    # Snyk
    if [[ -n "$snyk_token" ]]; then
        echo -e "  ${GREEN}✅ Snyk Integration${NC} - Org: $snyk_organization"
    else
        echo -e "  ${YELLOW}○ Snyk Integration${NC} - Optional (not configured)"
    fi
    
    echo ""
}

# Test Port.io credentials
test_port_credentials() {
    local client_id=$1
    local client_secret=$2
    
    print_info "Testing Port.io credentials..."
    
    local response=$(curl -s -X POST "https://api.getport.io/v1/auth/access_token" \
        -H "Content-Type: application/json" \
        -d "{\"clientId\": \"$client_id\", \"clientSecret\": \"$client_secret\"}")
    
    if echo "$response" | jq -e '.accessToken' > /dev/null 2>&1; then
        print_success "Port.io credentials are valid"
        return 0
    else
        print_error "Invalid Port.io credentials"
        echo "Response: $response"
        return 1
    fi
}

# Configure Port.io credentials
configure_port_credentials() {
    print_header "Port.io Credentials Configuration"
    
    echo "To get your Port.io credentials:"
    echo "1. Go to https://app.getport.io"
    echo "2. Navigate to Settings > Developers"
    echo "3. Create or use existing API credentials"
    echo ""
    
    # Show existing if available
    if [[ -n "$port_client_id" ]]; then
        echo -e "${BLUE}Current Client ID:${NC} $port_client_id"
        echo ""
        read -p "Keep existing Port.io credentials? (y/n): " keep_existing
        if [[ $keep_existing =~ ^[Yy]$ ]]; then
            print_success "Keeping existing Port.io credentials"
            return 0
        fi
    fi
    
    while true; do
        echo ""
        read -p "Enter your Port.io Client ID: " new_client_id
        read -s -p "Enter your Port.io Client Secret: " new_client_secret
        echo ""
        
        if [[ -z "$new_client_id" || -z "$new_client_secret" ]]; then
            print_warning "Both Client ID and Client Secret are required"
            continue
        fi
        
        if command -v curl &> /dev/null && command -v jq &> /dev/null; then
            if test_port_credentials "$new_client_id" "$new_client_secret"; then
                port_client_id="$new_client_id"
                port_client_secret="$new_client_secret"
                port_base_url="https://api.getport.io"
                print_success "Port.io credentials configured successfully"
                break
            else
                print_warning "Please check your credentials and try again"
            fi
        else
            print_warning "curl or jq not available, skipping credential validation"
            port_client_id="$new_client_id"
            port_client_secret="$new_client_secret"
            port_base_url="https://api.getport.io"
            print_success "Port.io credentials saved (validation skipped)"
            break
        fi
    done
}

# Configure environment settings
configure_environment() {
    print_header "Environment Configuration"
    
    # Show existing if available
    if [[ -n "$environment" && -n "$team_email" ]]; then
        echo -e "${BLUE}Current Environment:${NC} $environment"
        echo -e "${BLUE}Current Team Email:${NC} $team_email"
        echo ""
        read -p "Keep existing environment settings? (y/n): " keep_existing
        if [[ $keep_existing =~ ^[Yy]$ ]]; then
            print_success "Keeping existing environment settings"
            return 0
        fi
    fi
    
    echo "Select your deployment environment:"
    echo "1) Development"
    echo "2) Staging"
    echo "3) Production"
    echo ""
    
    while true; do
        read -p "Enter your choice (1-3): " env_choice
        case $env_choice in
            1) environment="dev"; break;;
            2) environment="staging"; break;;
            3) environment="prod"; break;;
            *) print_warning "Please enter 1, 2, or 3";;
        esac
    done
    
    while true; do
        echo ""
        read -p "Enter your team email address: " new_team_email
        if validate_email "$new_team_email"; then
            team_email="$new_team_email"
            break
        else
            print_warning "Please enter a valid email address"
        fi
    done
    
    print_success "Environment configuration saved"
}

# Configure AWS integration
configure_aws() {
    print_header "AWS Integration Configuration"
    
    # Show existing if available
    if [[ -n "$aws_access_key_id" ]]; then
        echo -e "${BLUE}Current AWS Access Key:${NC} ${aws_access_key_id:0:8}..."
        echo -e "${BLUE}Current AWS Region:${NC} $aws_region"
        echo ""
        read -p "Keep existing AWS configuration? (y/n): " keep_existing
        if [[ $keep_existing =~ ^[Yy]$ ]]; then
            print_success "Keeping existing AWS configuration"
            return 0
        fi
    fi
    
    echo "To get AWS credentials:"
    echo "1. Go to AWS IAM Console"
    echo "2. Create or use existing IAM user with appropriate permissions"
    echo "3. Generate access keys"
    echo ""
    
    read -p "Do you want to configure AWS integration? (y/n): " configure_aws
    
    if [[ $configure_aws =~ ^[Yy]$ ]]; then
        echo ""
        read -p "Enter AWS Access Key ID: " new_aws_access_key_id
        read -s -p "Enter AWS Secret Access Key: " new_aws_secret_access_key
        echo ""
        read -p "Enter AWS Region (default: us-west-2): " new_aws_region
        new_aws_region=${new_aws_region:-us-west-2}
        
        if [[ -n "$new_aws_access_key_id" && -n "$new_aws_secret_access_key" ]]; then
            aws_access_key_id="$new_aws_access_key_id"
            aws_secret_access_key="$new_aws_secret_access_key"
            aws_region="$new_aws_region"
            print_success "AWS configuration saved"
        else
            print_warning "AWS Access Key ID and Secret Key are required"
        fi
    else
        print_info "AWS integration skipped"
        # Clear existing AWS config if user chooses not to configure
        aws_access_key_id=""
        aws_secret_access_key=""
        aws_region=""
    fi
}

# Configure GitHub integration
configure_github() {
    print_header "GitHub Integration Configuration"
    
    # Show existing if available
    if [[ -n "$github_app_id" ]]; then
        echo -e "${BLUE}Current GitHub App ID:${NC} $github_app_id"
        echo -e "${BLUE}Current GitHub Organization:${NC} $github_organization"
        echo ""
        read -p "Keep existing GitHub configuration? (y/n): " keep_existing
        if [[ $keep_existing =~ ^[Yy]$ ]]; then
            print_success "Keeping existing GitHub configuration"
            return 0
        fi
    fi
    
    echo "To create a GitHub App:"
    echo "1. Go to GitHub Settings > Developer settings > GitHub Apps"
    echo "2. Click 'New GitHub App'"
    echo "3. Configure with repository read permissions"
    echo "4. Install the app in your organization"
    echo ""
    
    read -p "Do you want to configure GitHub integration? (y/n): " configure_github_var
    
    if [[ $configure_github_var =~ ^[Yy]$ ]]; then
        echo ""
        read -p "Enter GitHub App ID: " new_github_app_id
        read -p "Enter GitHub Installation ID: " new_github_installation_id
        read -p "Enter GitHub Organization: " new_github_organization
        read -p "Enter GitHub Actions Repository (default: port-infrastructure): " new_github_actions_repo
        new_github_actions_repo=${new_github_actions_repo:-port-infrastructure}
        
        echo ""
        echo "Enter GitHub App Private Key (paste the entire key, then press Ctrl+D):"
        new_github_private_key=$(cat)
        
        if [[ -n "$new_github_app_id" && -n "$new_github_installation_id" && -n "$new_github_organization" && -n "$new_github_private_key" ]]; then
            github_app_id="$new_github_app_id"
            github_installation_id="$new_github_installation_id"
            github_organization="$new_github_organization"
            github_actions_repo="$new_github_actions_repo"
            github_private_key="$new_github_private_key"
            github_actions_webhook_url="https://api.github.com/repos/$new_github_organization/$new_github_actions_repo/dispatches"
            print_success "GitHub configuration saved"
        else
            print_warning "All GitHub fields are required for proper configuration"
        fi
    else
        print_info "GitHub integration skipped"
        # Clear existing GitHub config
        github_app_id=""
        github_installation_id=""
        github_organization=""
        github_actions_repo=""
        github_private_key=""
        github_actions_webhook_url=""
    fi
}

# Configure Azure integration
configure_azure() {
    print_header "Azure Integration Configuration"
    
    # Show existing if available
    if [[ -n "$azure_client_id" ]]; then
        echo -e "${BLUE}Current Azure Client ID:${NC} $azure_client_id"
        echo -e "${BLUE}Current Azure Tenant ID:${NC} $azure_tenant_id"
        echo ""
        read -p "Keep existing Azure configuration? (y/n): " keep_existing
        if [[ $keep_existing =~ ^[Yy]$ ]]; then
            print_success "Keeping existing Azure configuration"
            return 0
        fi
    fi
    
    echo "To get Azure credentials:"
    echo "1. Go to Azure Active Directory > App registrations"
    echo "2. Create new registration or use existing"
    echo "3. Note the Application (client) ID and Directory (tenant) ID"
    echo "4. Create a client secret"
    echo ""
    
    read -p "Do you want to configure Azure integration? (y/n): " configure_azure_var
    
    if [[ $configure_azure_var =~ ^[Yy]$ ]]; then
        echo ""
        read -p "Enter Azure Client ID: " new_azure_client_id
        read -s -p "Enter Azure Client Secret: " new_azure_client_secret
        echo ""
        read -p "Enter Azure Tenant ID: " new_azure_tenant_id
        read -p "Enter Azure Subscription ID: " new_azure_subscription_id
        
        if [[ -n "$new_azure_client_id" && -n "$new_azure_client_secret" && -n "$new_azure_tenant_id" && -n "$new_azure_subscription_id" ]]; then
            azure_client_id="$new_azure_client_id"
            azure_client_secret="$new_azure_client_secret"
            azure_tenant_id="$new_azure_tenant_id"
            azure_subscription_id="$new_azure_subscription_id"
            print_success "Azure configuration saved"
        else
            print_warning "All Azure fields are required for proper configuration"
        fi
    else
        print_info "Azure integration skipped"
        # Clear existing Azure config
        azure_client_id=""
        azure_client_secret=""
        azure_tenant_id=""
        azure_subscription_id=""
    fi
}

# Configure Azure DevOps integration
configure_azure_devops() {
    print_header "Azure DevOps Integration Configuration"
    
    # Show existing if available
    if [[ -n "$azdo_organization_url" ]]; then
        echo -e "${BLUE}Current Azure DevOps Organization:${NC} $azdo_organization_url"
        echo ""
        read -p "Keep existing Azure DevOps configuration? (y/n): " keep_existing
        if [[ $keep_existing =~ ^[Yy]$ ]]; then
            print_success "Keeping existing Azure DevOps configuration"
            return 0
        fi
    fi
    
    echo "To get Azure DevOps credentials:"
    echo "1. Go to Azure DevOps > User settings > Personal access tokens"
    echo "2. Create new token with appropriate permissions"
    echo ""
    
    read -p "Do you want to configure Azure DevOps integration? (y/n): " configure_azdo
    
    if [[ $configure_azdo =~ ^[Yy]$ ]]; then
        echo ""
        read -p "Enter Azure DevOps Organization URL: " new_azdo_organization_url
        read -s -p "Enter Azure DevOps Personal Access Token: " new_azdo_personal_token
        echo ""
        
        if [[ -n "$new_azdo_organization_url" && -n "$new_azdo_personal_token" ]]; then
            azdo_organization_url="$new_azdo_organization_url"
            azdo_personal_token="$new_azdo_personal_token"
            print_success "Azure DevOps configuration saved"
        else
            print_warning "Both Organization URL and Personal Token are required"
        fi
    else
        print_info "Azure DevOps integration skipped"
        # Clear existing Azure DevOps config
        azdo_organization_url=""
        azdo_personal_token=""
    fi
}

# Configure Snyk integration
configure_snyk() {
    print_header "Snyk Integration Configuration"
    
    # Show existing if available
    if [[ -n "$snyk_token" ]]; then
        echo -e "${BLUE}Current Snyk Organization:${NC} $snyk_organization"
        echo ""
        read -p "Keep existing Snyk configuration? (y/n): " keep_existing
        if [[ $keep_existing =~ ^[Yy]$ ]]; then
            print_success "Keeping existing Snyk configuration"
            return 0
        fi
    fi
    
    echo "To get Snyk credentials:"
    echo "1. Go to Snyk account settings"
    echo "2. Generate or copy your API token"
    echo "3. Note your organization ID"
    echo ""
    
    read -p "Do you want to configure Snyk integration? (y/n): " configure_snyk_var
    
    if [[ $configure_snyk_var =~ ^[Yy]$ ]]; then
        echo ""
        read -s -p "Enter Snyk API Token: " new_snyk_token
        echo ""
        read -p "Enter Snyk Organization ID: " new_snyk_organization
        
        if [[ -n "$new_snyk_token" && -n "$new_snyk_organization" ]]; then
            snyk_token="$new_snyk_token"
            snyk_organization="$new_snyk_organization"
            print_success "Snyk configuration saved"
        else
            print_warning "Both Snyk Token and Organization ID are required"
        fi
    else
        print_info "Snyk integration skipped"
        # Clear existing Snyk config
        snyk_token=""
        snyk_organization=""
    fi
}

# Save configuration to file
save_configuration() {
    print_header "Saving Configuration"
    
    # Check if we have required components
    if [[ -z "$port_client_id" || -z "$port_client_secret" ]]; then
        print_error "Port.io credentials are required before saving!"
        return 1
    fi
    
    if [[ -z "$environment" || -z "$team_email" ]]; then
        print_error "Environment settings are required before saving!"
        return 1
    fi
    
    # Backup existing file if it exists
    if [[ -f "$CONFIG_FILE" ]]; then
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        print_info "Backed up existing configuration to $BACKUP_FILE"
    fi
    
    # Write configuration file
    cat > "$CONFIG_FILE" << EOF
# Port.io Infrastructure Configuration
# Generated by setup script on $(date)

# Port.io Configuration (Required)
port_client_id     = "$port_client_id"
port_client_secret = "$port_client_secret"
port_base_url      = "$port_base_url"

# Environment Configuration
environment = "$environment"
team_email  = "$team_email"

EOF

    # Add AWS configuration if provided
    if [[ -n "$aws_access_key_id" ]]; then
        cat >> "$CONFIG_FILE" << EOF
# AWS Configuration
aws_access_key_id     = "$aws_access_key_id"
aws_secret_access_key = "$aws_secret_access_key"
aws_region           = "$aws_region"

EOF
    fi
    
    # Add Azure configuration if provided
    if [[ -n "$azure_client_id" ]]; then
        cat >> "$CONFIG_FILE" << EOF
# Azure Configuration
azure_client_id       = "$azure_client_id"
azure_client_secret   = "$azure_client_secret"
azure_tenant_id       = "$azure_tenant_id"
azure_subscription_id = "$azure_subscription_id"

EOF
    fi
    
    # Add GitHub configuration if provided
    if [[ -n "$github_app_id" ]]; then
        cat >> "$CONFIG_FILE" << EOF
# GitHub Configuration
github_app_id          = "$github_app_id"
github_private_key     = <<-EOF_KEY
$github_private_key
EOF_KEY
github_installation_id = "$github_installation_id"
github_actions_webhook_url = "$github_actions_webhook_url"

EOF
    fi
    
    # Add Azure DevOps configuration if provided
    if [[ -n "$azdo_organization_url" ]]; then
        cat >> "$CONFIG_FILE" << EOF
# Azure DevOps Configuration
azdo_organization_url = "$azdo_organization_url"
azdo_personal_token   = "$azdo_personal_token"

EOF
    fi
    
    # Add Snyk configuration if provided
    if [[ -n "$snyk_token" ]]; then
        cat >> "$CONFIG_FILE" << EOF
# Snyk Configuration
snyk_token        = "$snyk_token"
snyk_organization = "$snyk_organization"

EOF
    fi
    
    # Add team and optional configuration
    cat >> "$CONFIG_FILE" << EOF
# Optional Configuration
enable_audit_logging     = true
drift_detection_schedule = "0 2 * * 1"  # Weekly on Monday at 2 AM
sync_schedule           = "0 1 * * *"   # Daily at 1 AM

# Team Configuration
available_teams = [
  "platform",
  "backend",
  "frontend",
  "mobile",
  "data"
]

approval_recipients = [
  "$team_email"
]

github_organization = "$github_organization"
github_actions_repo = "$github_actions_repo"

# Webhook URLs for actions (update these with your actual endpoints)
dora_webhook_url            = "https://your-dora-metrics-service.com/webhook"
dora_collection_webhook_url = "https://your-dora-collector.com/webhook"
port_webhook_url           = "https://your-port-webhook-handler.com/webhook"
EOF
    
    print_success "Configuration saved to $CONFIG_FILE"
    return 0
}

# Main menu
show_main_menu() {
    clear
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 Port.io Infrastructure Setup                ║"
    echo "║                    Menu-Driven Configuration                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    show_config_status
    
    echo -e "${CYAN}Configuration Menu:${NC}"
    echo "  1) Configure Port.io Credentials (Required)"
    echo "  2) Configure Environment Settings (Required)"
    echo "  3) Configure AWS Integration"
    echo "  4) Configure GitHub Integration"
    echo "  5) Configure Azure Integration"
    echo "  6) Configure Azure DevOps Integration"
    echo "  7) Configure Snyk Integration"
    echo ""
    echo -e "${GREEN}  s) Save Configuration${NC}"
    echo -e "${YELLOW}  r) Reload Configuration${NC}"
    echo -e "${RED}  q) Quit${NC}"
    echo ""
}

# Main execution loop
main() {
    # Load existing configuration
    load_existing_config
    
    while true; do
        show_main_menu
        read -p "Select an option: " choice
        
        case $choice in
            1)
                configure_port_credentials
                ;;
            2)
                configure_environment
                ;;
            3)
                configure_aws
                ;;
            4)
                configure_github
                ;;
            5)
                configure_azure
                ;;
            6)
                configure_azure_devops
                ;;
            7)
                configure_snyk
                ;;
            s|S)
                if save_configuration; then
                    echo ""
                    read -p "Configuration saved successfully! Press Enter to continue..."
                else
                    echo ""
                    read -p "Failed to save configuration. Press Enter to continue..."
                fi
                ;;
            r|R)
                load_existing_config
                echo ""
                read -p "Configuration reloaded. Press Enter to continue..."
                ;;
            q|Q)
                echo ""
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                echo ""
                print_warning "Invalid option. Please try again."
                sleep 2
                ;;
        esac
    done
}

# Run the script
main "$@"
