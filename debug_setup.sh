#!/bin/bash

# Debug version of the setup script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CONFIG_FILE="terraform.tfvars"

print_header() {
    echo -e "\n${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Get configuration value from terraform.tfvars
get_config_value() {
    local key=$1
    if [[ -f "$CONFIG_FILE" ]]; then
        grep "^$key" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 | sed 's/[" ]//g' | head -1
    fi
}

load_existing_config() {
    echo "DEBUG: Checking if $CONFIG_FILE exists..."
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "DEBUG: No config file found, returning 1"
        return 1
    fi
    echo "DEBUG: Config file found, loading..."
    return 0
}

check_existing_config() {
    echo "DEBUG: In check_existing_config function"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "DEBUG: No config file, returning 1"
        return 1
    fi
    
    print_header "Checking Existing Configuration"
    print_success "Found existing configuration"
    return 0
}

show_config_menu() {
    print_header "Configuration Menu"
    
    echo "Select what you want to configure/update:"
    echo ""
    echo "1) Port.io credentials (Required)"
    echo "2) Environment settings"
    echo "3) AWS integration"
    echo "4) GitHub integration"
    echo "5) Azure integration"
    echo "6) Azure DevOps integration"
    echo "7) Snyk integration"
    echo "8) Team configuration"
    echo "9) Configure all missing components"
    echo "0) Continue with current configuration"
    echo ""
}

interactive_config() {
    echo "DEBUG: In interactive_config function"
    show_config_menu
    read -p "Enter your choice (0-9): " choice
    echo "You selected: $choice"
}

# Simple test main function
main() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                Debug Port.io Setup Script                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    echo "DEBUG: Starting main function"
    
    echo "DEBUG: About to call load_existing_config"
    load_existing_config
    local config_loaded=$?
    echo "DEBUG: load_existing_config returned: $config_loaded"
    
    echo "DEBUG: About to call check_existing_config"
    if check_existing_config; then
        echo "DEBUG: Config exists, asking for mode"
        echo ""
        read -p "Configuration file found. Do you want to update specific components or start fresh? (update/fresh): " mode
        echo "DEBUG: Mode selected: $mode"
        
        case $mode in
            "update"|"u")
                echo "DEBUG: Calling interactive_config"
                interactive_config
                ;;
            "fresh"|"f")
                echo "DEBUG: Starting fresh configuration"
                ;;
            *)
                echo "DEBUG: Using update mode by default"
                interactive_config
                ;;
        esac
    else
        echo "DEBUG: No existing configuration found. Starting initial setup..."
        print_info "Would start fresh setup here"
    fi
    
    print_success "Debug script completed!"
}

echo "DEBUG: About to call main function"
main "$@"
echo "DEBUG: Script finished"
