#!/bin/bash

# Port.io Infrastructure Setup Script
# This script helps gather required credentials and configurations
# to deploy and interact with Port.io programmatically

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration file
CONFIG_FILE="terraform.tfvars"
BACKUP_FILE="terraform.tfvars.backup.$(date +%Y%m%d_%H%M%S)"

# Print colored output
print_header() {
    echo -e "\n${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}\n"
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
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Validate required tools
validate_dependencies() {
    print_header "Validating Dependencies"
    
    local missing_tools=()
    
    if ! command -v tofu &> /dev/null; then
        missing_tools+=("OpenTofu")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if [ ${#missing_tools[@]} -eq 0 ]; then
        print_success "All required tools are installed"
    else
        print_error "Missing required tools: ${missing_tools[*]}"
        echo "Please install the missing tools and run this script again."
        exit 1
    fi
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
        return 1
    fi
}

# Gather Port.io configuration
gather_port_config() {
    print_header "Port.io Configuration"
    
    echo "To get your Port.io credentials:"
    echo "1. Go to https://app.getport.io"
    echo "2. Navigate to Settings > Developers"
    echo "3. Create or use existing API credentials"
    echo ""
    
    while true; do
        read -p "Enter your Port.io Client ID: " PORT_CLIENT_ID
        read -s -p "Enter your Port.io Client Secret: " PORT_CLIENT_SECRET
        echo ""
        
        if test_port_credentials "$PORT_CLIENT_ID" "$PORT_CLIENT_SECRET"; then
            break
        else
            print_warning "Please check your credentials and try again"
            PORT_CLIENT_ID=""
            PORT_CLIENT_SECRET=""
        fi
    done
}

# Gather environment configuration
gather_environment_config() {
    print_header "Environment Configuration"
    
    echo "Select your deployment environment:"
    echo "1) Development"
    echo "2) Staging" 
    echo "3) Production"
    
    while true; do
        read -p "Enter your choice (1-3): " env_choice
        case $env_choice in
            1) ENVIRONMENT="dev"; break;;
            2) ENVIRONMENT="staging"; break;;
            3) ENVIRONMENT="prod"; break;;
            *) print_warning "Please enter 1, 2, or 3";;
        esac
    done
    
    read -p "Enter your team email address: " TEAM_EMAIL
}

# Gather GitHub configuration
gather_github_config() {
    print_header "GitHub Configuration"
    
    read -p "Do you want to configure GitHub integration? (y/n): " configure_github
    
    if [[ $configure_github =~ ^[Yy]$ ]]; then
        echo ""
        echo "To create a GitHub App:"
        echo "1. Go to GitHub Settings > Developer settings > GitHub Apps"
        echo "2. Click 'New GitHub App'"
        echo "3. Configure with repository read permissions"
        echo "4. Install the app in your organization"
        echo ""
        
        read -p "Enter GitHub App ID: " GITHUB_APP_ID
        read -p "Enter GitHub Installation ID: " GITHUB_INSTALLATION_ID
        read -p "Enter GitHub Organization: " GITHUB_ORGANIZATION
        read -p "Enter GitHub Actions Repository (default: port-infrastructure): " GITHUB_ACTIONS_REPO
        GITHUB_ACTIONS_REPO=${GITHUB_ACTIONS_REPO:-port-infrastructure}
        
        echo "Enter GitHub App Private Key (paste the entire key, then press Ctrl+D):"
        GITHUB_PRIVATE_KEY=$(cat)
    else
        print_info "GitHub integration skipped"
        GITHUB_APP_ID=""
        GITHUB_INSTALLATION_ID=""
        GITHUB_PRIVATE_KEY=""
        GITHUB_ORGANIZATION=""
        GITHUB_ACTIONS_REPO=""
    fi
}

# Component selection function
select_components_to_configure() {
    print_header "Component Selection"
    
    echo "Select which components you want to configure:"
    echo ""
    echo "Available components:"
    echo "1) Port.io credentials (Required)"
    echo "2) Environment settings (Required)"
    echo "3) GitHub integration"
    echo ""
    echo "Enter the numbers of components you want to configure (space-separated):"
    echo "Example: '1 2 3' to configure all components"
    echo ""
    
    read -p "Your selection: " selection
    
    echo ""
    print_info "Configuring selected components..."
    echo ""
    
    # Parse selection and execute configurations
    for num in $selection; do
        case $num in
            1) 
                print_info "Configuring Port.io credentials..."
                gather_port_config
                ;;
            2) 
                print_info "Configuring environment settings..."
                gather_environment_config
                ;;
            3) 
                print_info "Configuring GitHub integration..."
                gather_github_config
                ;;
            *) 
                print_warning "Ignoring invalid selection: $num"
                ;;
        esac
    done
    
    print_success "Component configuration complete!"
}

# Write configuration file
write_config_file() {
    print_header "Writing Configuration"
    
    # Backup existing file if it exists
    if [[ -f "$CONFIG_FILE" ]]; then
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        print_info "Backed up existing configuration to $BACKUP_FILE"
    fi
    
    cat > "$CONFIG_FILE" << EOF
# Port.io Infrastructure Configuration
# Generated by setup script on $(date)

# Port.io Configuration (Required)
port_client_id     = "$PORT_CLIENT_ID"
port_client_secret = "$PORT_CLIENT_SECRET"
port_base_url      = "https://api.getport.io"

# Environment Configuration
environment = "$ENVIRONMENT"
team_email  = "$TEAM_EMAIL"
EOF

    # Add GitHub configuration if provided
    if [[ -n "$GITHUB_APP_ID" ]]; then
        cat >> "$CONFIG_FILE" << EOF

# GitHub Configuration
github_app_id          = "$GITHUB_APP_ID"
github_private_key     = <<-EOF_KEY
$GITHUB_PRIVATE_KEY
EOF_KEY
github_installation_id = "$GITHUB_INSTALLATION_ID"
github_organization    = "$GITHUB_ORGANIZATION"
github_actions_repo    = "$GITHUB_ACTIONS_REPO"
EOF
    fi
    
    print_success "Configuration written to $CONFIG_FILE"
}

# Create helper scripts
create_helper_scripts() {
    print_header "Creating Helper Scripts"
    
    # Create a simple Port API interaction script
    cat > "port-cli.sh" << 'EOF'
#!/bin/bash

# Simple Port.io CLI helper script
# Usage: ./port-cli.sh <command> [args]

# Load configuration
if [[ -f "terraform.tfvars" ]]; then
    source terraform.tfvars 2>/dev/null || {
        # If sourcing fails, try to extract values manually
        PORT_CLIENT_ID=$(grep 'port_client_id' terraform.tfvars | cut -d'"' -f2)
        PORT_CLIENT_SECRET=$(grep 'port_client_secret' terraform.tfvars | cut -d'"' -f2)
    }
fi

get_port_token() {
    curl -s -X POST "https://api.getport.io/v1/auth/access_token" \
        -H "Content-Type: application/json" \
        -d "{\"clientId\": \"$PORT_CLIENT_ID\", \"clientSecret\": \"$PORT_CLIENT_SECRET\"}" | \
        jq -r '.accessToken'
}

case "$1" in
    "blueprints")
        TOKEN=$(get_port_token)
        curl -s -H "Authorization: Bearer $TOKEN" \
            "https://api.getport.io/v1/blueprints" | jq '.'
        ;;
    "entities")
        TOKEN=$(get_port_token)
        BLUEPRINT=${2:-"microservice"}
        curl -s -H "Authorization: Bearer $TOKEN" \
            "https://api.getport.io/v1/blueprints/$BLUEPRINT/entities" | jq '.'
        ;;
    "integrations")
        TOKEN=$(get_port_token)
        curl -s -H "Authorization: Bearer $TOKEN" \
            "https://api.getport.io/v1/integrations" | jq '.'
        ;;
    *)
        echo "Usage: $0 {blueprints|entities|integrations} [blueprint_name]"
        exit 1
        ;;
esac
EOF
    
    chmod +x port-cli.sh
    print_success "Created port-cli.sh helper script"
}

# Main execution
main() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 Port.io Infrastructure Setup                ║"
    echo "║                                                              ║"
    echo "║  This script will help you configure and deploy your        ║"
    echo "║  Port.io software catalog infrastructure using OpenTofu     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    validate_dependencies
    
    # Component selection
    select_components_to_configure
    
    # Write configuration and create helper scripts
    write_config_file
    create_helper_scripts
    
    print_header "Setup Complete!"
    
    echo "Next steps:"
    echo "1. Review the generated terraform.tfvars file"
    echo "2. Run './validate.sh' to validate your configuration"
    echo "3. Run 'tofu plan' to see what will be deployed"
    echo "4. Run 'tofu apply' to deploy your infrastructure"
    echo "5. Use './port-cli.sh' to interact with Port.io API"
    echo ""
    print_success "Port.io infrastructure setup is ready!"
}

# Run main function
main "$@"