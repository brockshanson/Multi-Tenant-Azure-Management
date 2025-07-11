#!/bin/bash

# Load environment variables for multi-tenant Azure management

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ENV_FILE=".env.local"

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

if [ ! -f "$ENV_FILE" ]; then
    print_error "Environment file $ENV_FILE not found"
    print_info "Run './scripts/utilities/setup-azure-credentials.sh' to create it"
    print_info "Or copy config/templates/.env.template to .env.local and configure manually"
    exit 1
fi

# Check file permissions
file_perms=$(stat -f "%OLp" "$ENV_FILE" 2>/dev/null || stat -c "%a" "$ENV_FILE" 2>/dev/null)
if [ "$file_perms" != "600" ]; then
    print_warning "Insecure file permissions on $ENV_FILE (current: $file_perms)"
    print_info "Setting secure permissions (600)..."
    chmod 600 "$ENV_FILE"
    print_success "File permissions updated to 600"
fi

# Load environment variables
set -a
source "$ENV_FILE"
set +a

print_success "Environment variables loaded from $ENV_FILE"

# Verify required variables are set (without exposing values)
required_vars=(
    "AZURE_TENANT_1_ID"
    "AZURE_CLIENT_1_ID" 
    "AZURE_CLIENT_1_SECRET"
    "AZURE_TENANT_2_ID"
    "AZURE_CLIENT_2_ID"
    "AZURE_CLIENT_2_SECRET"
)

missing_vars=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    print_error "Missing required environment variables:"
    printf '  %s\n' "${missing_vars[@]}"
    print_info "Update your $ENV_FILE file with the missing values"
    exit 1
fi

print_success "All required environment variables are set"

# Show tenant information (safe to display)
print_info "Configured tenants:"
echo "  • Tenant 1: $AZURE_TENANT_1_ID (Dasein Research Group)"
echo "  • Tenant 2: $AZURE_TENANT_2_ID (Spectral Solutions)"

# Reminder about usage
print_info "To use these variables, run this command in your shell:"
echo "  source scripts/utilities/load-env.sh"
