#!/bin/bash

# Check environment variables and optionally test Azure authentication

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Parse command line arguments
TEST_AUTH=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --test-auth)
            TEST_AUTH=true
            shift
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--test-auth] [--quiet] [--help]"
            echo ""
            echo "Options:"
            echo "  --test-auth  Test Azure authentication for both tenants"
            echo "  --quiet      Suppress informational output"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$QUIET" = false ]; then
    print_info "Checking environment variable configuration..."
fi

required_vars=(
    "AZURE_TENANT_1_ID"
    "AZURE_CLIENT_1_ID" 
    "AZURE_CLIENT_1_SECRET"
    "AZURE_TENANT_2_ID"
    "AZURE_CLIENT_2_ID"
    "AZURE_CLIENT_2_SECRET"
)

all_set=true
missing_vars=()

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        print_error "$var is not set"
        all_set=false
        missing_vars+=("$var")
    else
        if [ "$QUIET" = false ]; then
            print_success "$var is configured"
        fi
    fi
done

if [ "$all_set" = false ]; then
    echo ""
    print_error "Missing environment variables: ${missing_vars[*]}"
    print_info "Run 'source scripts/utilities/load-env.sh' to load from .env.local"
    print_info "Or run './scripts/utilities/setup-azure-credentials.sh' to set up from scratch"
    exit 1
fi

if [ "$QUIET" = false ]; then
    echo ""
    print_success "All required environment variables are properly configured!"
    
    # Show tenant information
    print_info "Configured tenants:"
    echo "  • Dasein Research Group: $AZURE_TENANT_1_ID"
    echo "  • Spectral Solutions: $AZURE_TENANT_2_ID"
fi

# Test authentication if requested
if [ "$TEST_AUTH" = true ]; then
    if [ "$QUIET" = false ]; then
        echo ""
        print_info "Testing Azure authentication..."
    fi
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed"
        exit 1
    fi
    
    # Test tenant 1 authentication
    print_info "Testing Dasein Research Group authentication..."
    if az login --service-principal \
        --username "$AZURE_CLIENT_1_ID" \
        --password "$AZURE_CLIENT_1_SECRET" \
        --tenant "$AZURE_TENANT_1_ID" \
        --only-show-errors > /dev/null 2>&1; then
        
        # Test Graph API access
        org_name=$(az rest --method GET --uri "https://graph.microsoft.com/v1.0/organization" \
            --query "value[0].displayName" -o tsv 2>/dev/null)
        
        if [ -n "$org_name" ]; then
            print_success "Dasein Research Group authentication successful ($org_name)"
        else
            print_warning "Dasein authentication successful but Graph API access failed"
        fi
    else
        print_error "Dasein Research Group authentication failed"
        exit 1
    fi
    
    # Test tenant 2 authentication
    print_info "Testing Spectral Solutions authentication..."
    if az login --service-principal \
        --username "$AZURE_CLIENT_2_ID" \
        --password "$AZURE_CLIENT_2_SECRET" \
        --tenant "$AZURE_TENANT_2_ID" \
        --only-show-errors > /dev/null 2>&1; then
        
        # Test Graph API access
        org_name=$(az rest --method GET --uri "https://graph.microsoft.com/v1.0/organization" \
            --query "value[0].displayName" -o tsv 2>/dev/null)
        
        if [ -n "$org_name" ]; then
            print_success "Spectral Solutions authentication successful ($org_name)"
        else
            print_warning "Spectral authentication successful but Graph API access failed"
        fi
    else
        print_error "Spectral Solutions authentication failed"
        exit 1
    fi
    
    if [ "$QUIET" = false ]; then
        echo ""
        print_success "🎉 All authentication tests passed!"
    fi
fi

exit 0
