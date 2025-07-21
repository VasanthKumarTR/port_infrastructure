#!/bin/bash

# Port.io Infrastructure Validation Script
# This script validates your configuration before deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_FILE="terraform.tfvars"

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

# Extract value from terraform.tfvars
get_config_value() {
    local key=$1
    grep "^$key" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 | sed 's/[" ]//g' || echo ""
}

# Validate file exists
validate_config_file() {
    print_header "Validating Configuration File"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file $CONFIG_FILE not found"
        echo "Please run setup.sh or setup.py first"
        exit 1
    fi
    
    print_success "Configuration file found"
}

# Validate OpenTofu
validate_terraform() {
    print_header "Validating OpenTofu Configuration"
    
    print_info "Initializing OpenTofu..."
    if tofu init > /dev/null 2>&1; then
        print_success "OpenTofu initialized successfully"
    else
        print_error "Failed to initialize OpenTofu"
        return 1
    fi
    
    print_info "Validating configuration..."
    if tofu validate > /dev/null 2>&1; then
        print_success "Configuration is valid"
    else
        print_error "Configuration validation failed"
        tofu validate
        return 1
    fi
}

# Test Port.io credentials
test_port_credentials() {
    print_header "Testing Port.io Credentials"
    
    local client_id=$(get_config_value "port_client_id")
    local client_secret=$(get_config_value "port_client_secret")
    
    if [[ -z "$client_id" || -z "$client_secret" ]]; then
        print_error "Port.io credentials not found in configuration"
        return 1
    fi
    
    print_info "Testing Port.io API access..."
    
    local response=$(curl -s -X POST "https://api.getport.io/v1/auth/access_token" \
        -H "Content-Type: application/json" \
        -d "{\"clientId\": \"$client_id\", \"clientSecret\": \"$client_secret\"}")
    
    if echo "$response" | jq -e '.accessToken' > /dev/null 2>&1; then
        print_success "Port.io credentials are valid"
        
        # Test getting blueprints
        local token=$(echo "$response" | jq -r '.accessToken')
        local blueprints=$(curl -s -H "Authorization: Bearer $token" \
            "https://api.getport.io/v1/blueprints")
        
        if echo "$blueprints" | jq -e '.blueprints' > /dev/null 2>&1; then
            local count=$(echo "$blueprints" | jq '.blueprints | length')
            print_info "Found $count existing blueprints"
        fi
        
        return 0
    else
        print_error "Invalid Port.io credentials"
        echo "Response: $response"
        return 1
    fi
}

# Test AWS credentials
test_aws_credentials() {
    print_header "Testing AWS Credentials"
    
    local access_key=$(get_config_value "aws_access_key_id")
    local secret_key=$(get_config_value "aws_secret_access_key")
    local region=$(get_config_value "aws_region")
    
    if [[ -z "$access_key" ]]; then
        print_warning "AWS credentials not configured, skipping AWS validation"
        return 0
    fi
    
    if ! command -v aws &> /dev/null; then
        print_warning "AWS CLI not found, skipping AWS credential validation"
        return 0
    fi
    
    print_info "Testing AWS credentials..."
    
    export AWS_ACCESS_KEY_ID="$access_key"
    export AWS_SECRET_ACCESS_KEY="$secret_key"
    export AWS_DEFAULT_REGION="$region"
    
    if aws sts get-caller-identity &> /dev/null; then
        local identity=$(aws sts get-caller-identity)
        local account=$(echo "$identity" | jq -r '.Account')
        local user=$(echo "$identity" | jq -r '.UserId')
        print_success "AWS credentials are valid (Account: $account, User: $user)"
    else
        print_error "Invalid AWS credentials"
        unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION
        return 1
    fi
    
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION
}

# Test GitHub configuration
test_github_config() {
    print_header "Testing GitHub Configuration"
    
    local app_id=$(get_config_value "github_app_id")
    local installation_id=$(get_config_value "github_installation_id")
    local organization=$(get_config_value "github_organization")
    
    if [[ -z "$app_id" ]]; then
        print_warning "GitHub configuration not found, skipping GitHub validation"
        return 0
    fi
    
    print_info "Validating GitHub configuration..."
    
    if [[ -n "$app_id" && -n "$installation_id" && -n "$organization" ]]; then
        print_success "GitHub configuration appears complete"
        print_info "App ID: $app_id, Installation ID: $installation_id, Organization: $organization"
    else
        print_warning "GitHub configuration incomplete"
        return 1
    fi
}

# Test Azure configuration
test_azure_config() {
    print_header "Testing Azure Configuration"
    
    local client_id=$(get_config_value "azure_client_id")
    local tenant_id=$(get_config_value "azure_tenant_id")
    
    if [[ -z "$client_id" ]]; then
        print_warning "Azure configuration not found, skipping Azure validation"
        return 0
    fi
    
    print_info "Validating Azure configuration..."
    
    if [[ -n "$client_id" && -n "$tenant_id" ]]; then
        print_success "Azure configuration appears complete"
        print_info "Client ID: $client_id, Tenant ID: $tenant_id"
    else
        print_warning "Azure configuration incomplete"
        return 1
    fi
}

# Generate deployment plan
generate_plan() {
    print_header "Generating Deployment Plan"
    
    print_info "Creating OpenTofu plan..."
    if tofu plan -out=tfplan > tfplan.log 2>&1; then
        print_success "Deployment plan generated successfully"
        
        # Show plan summary
        echo ""
        print_info "Deployment Plan Summary:"
        echo "========================"
        
        # Extract resource counts from plan
        local to_add=$(grep "# .* will be created" tfplan.log | wc -l | tr -d ' ')
        local to_change=$(grep "# .* will be updated" tfplan.log | wc -l | tr -d ' ')
        local to_destroy=$(grep "# .* will be destroyed" tfplan.log | wc -l | tr -d ' ')
        
        echo "Resources to be created: $to_add"
        echo "Resources to be changed: $to_change"
        echo "Resources to be destroyed: $to_destroy"
        
        echo ""
        print_info "Port.io resources to be created:"
        grep "# port_" tfplan.log | grep "will be created" | sed 's/^.*# /  - /' | sed 's/ will be created//'
        
        echo ""
        print_success "Plan saved to tfplan file"
        print_info "Review the full plan in tfplan.log"
        
    else
        print_error "Failed to generate deployment plan"
        cat tfplan.log
        return 1
    fi
}

# Check for common issues
check_common_issues() {
    print_header "Checking for Common Issues"
    
    # Check for required variables
    local required_vars=("port_client_id" "port_client_secret" "environment" "team_email")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [[ -z "$(get_config_value "$var")" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -eq 0 ]]; then
        print_success "All required variables are configured"
    else
        print_error "Missing required variables: ${missing_vars[*]}"
        return 1
    fi
    
    # Check email format
    local team_email=$(get_config_value "team_email")
    if [[ $team_email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_success "Team email format is valid"
    else
        print_warning "Team email format may be invalid: $team_email"
    fi
    
    # Check for placeholder values
    if grep -q "your-.*-here\|yourcompany\|yourorganization" "$CONFIG_FILE"; then
        print_warning "Found placeholder values in configuration - please update them"
        grep "your-.*-here\|yourcompany\|yourorganization" "$CONFIG_FILE"
    else
        print_success "No placeholder values found"
    fi
}

# Network connectivity test
test_connectivity() {
    print_header "Testing Network Connectivity"
    
    local endpoints=(
        "https://api.getport.io"
        "https://api.github.com"
        "https://registry.opentofu.org"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if curl -s --connect-timeout 5 "$endpoint" > /dev/null; then
            print_success "Can reach $endpoint"
        else
            print_warning "Cannot reach $endpoint - check network connectivity"
        fi
    done
}

# Main execution
main() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              Port.io Infrastructure Validation              ║"
    echo "║                                                              ║"
    echo "║  This script validates your configuration before deployment  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    local failed_checks=0
    
    # Run all validation checks
    validate_config_file || ((failed_checks++))
    check_common_issues || ((failed_checks++))
    test_connectivity || ((failed_checks++))
    validate_terraform || ((failed_checks++))
    test_port_credentials || ((failed_checks++))
    test_aws_credentials || ((failed_checks++))
    test_github_config || ((failed_checks++))
    test_azure_config || ((failed_checks++))
    generate_plan || ((failed_checks++))
    
    echo ""
    print_header "Validation Summary"
    
    if [[ $failed_checks -eq 0 ]]; then
        print_success "All validation checks passed! ✨"
        echo ""
        echo "Your configuration is ready for deployment. You can now run:"
        echo "  tofu apply tfplan"
        echo ""
        echo "Or use the helper script:"
        echo "  ./deploy.sh"
    else
        print_error "$failed_checks validation check(s) failed"
        echo ""
        echo "Please fix the issues above before deploying."
        echo "You can re-run this validation script anytime with:"
        echo "  ./validate.sh"
        exit 1
    fi
}

main "$@"
