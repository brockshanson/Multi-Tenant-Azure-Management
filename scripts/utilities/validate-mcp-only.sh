#!/bin/bash
# validate-mcp-only.sh
# Test Lokka MCP authentication without Azure CLI dependency

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

ENV_FILE=".env.local"

print_info "MCP-Only Authentication Validation"
echo "=================================="
echo ""

# Check if environment file exists
if [ ! -f "$ENV_FILE" ]; then
    print_error "Environment file $ENV_FILE not found"
    print_info "Create it using: cp config/templates/.env.template .env.local"
    exit 1
fi

# Load environment variables
set -a
source "$ENV_FILE"
set +a

# Check required variables
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
    exit 1
fi

print_success "All environment variables are configured"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed"
    print_info "Install from: https://nodejs.org/"
    exit 1
fi

print_success "Node.js is installed ($(node --version))"

# Check if Lokka MCP is installed
if ! command -v lokka-mcp &> /dev/null; then
    print_error "Lokka MCP is not installed"
    print_info "Install with: npm install -g lokka-mcp"
    exit 1
fi

print_success "Lokka MCP is installed"

echo ""
print_info "Testing authentication for both tenants..."
echo ""

# Test Dasein Research Group (Tenant 1)
print_info "Testing Dasein Research Group authentication..."

if lokka-mcp \
    --tenant-id "$AZURE_TENANT_1_ID" \
    --client-id "$AZURE_CLIENT_1_ID" \
    --client-secret "$AZURE_CLIENT_1_SECRET" \
    --scope "https://graph.microsoft.com/.default" \
    --validate-only > /dev/null 2>&1; then
    
    print_success "Dasein Research Group authentication successful"
else
    print_error "Dasein Research Group authentication failed"
    print_info "Check your credentials in $ENV_FILE"
    print_info "Verify app registration permissions in Azure Portal"
    exit 1
fi

# Test Spectral Solutions (Tenant 2)
print_info "Testing Spectral Solutions authentication..."

if lokka-mcp \
    --tenant-id "$AZURE_TENANT_2_ID" \
    --client-id "$AZURE_CLIENT_2_ID" \
    --client-secret "$AZURE_CLIENT_2_SECRET" \
    --scope "https://graph.microsoft.com/.default" \
    --validate-only > /dev/null 2>&1; then
    
    print_success "Spectral Solutions authentication successful"
else
    print_error "Spectral Solutions authentication failed"
    print_info "Check your credentials in $ENV_FILE"
    print_info "Verify app registration permissions in Azure Portal"
    exit 1
fi

echo ""
print_success "🎉 All MCP authentication tests passed!"
echo ""
print_info "You can now:"
echo "  1. Start your MCP client (VS Code, Claude Desktop, etc.)"
echo "  2. Test queries like: 'Show me organization details for both tenants'"
echo "  3. Begin multi-tenant operations"
echo ""
print_info "No Azure CLI required for runtime operations!"

exit 0
