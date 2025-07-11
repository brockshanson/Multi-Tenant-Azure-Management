#!/bin/bash
# merge-claude-config.sh
# Safely merge Lokka MCP servers into existing Claude Desktop configuration

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

# Determine Claude config path based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CLAUDE_CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    CLAUDE_CONFIG_PATH="$APPDATA/Claude/claude_desktop_config.json"
else
    print_error "Unsupported operating system: $OSTYPE"
    exit 1
fi

print_info "Claude Desktop MCP Configuration Merger"
echo "======================================"
echo ""

# Check if template exists
TEMPLATE_PATH="config/templates/mcp-servers-template.json"
if [ ! -f "$TEMPLATE_PATH" ]; then
    print_error "Template file not found: $TEMPLATE_PATH"
    print_info "Make sure you're running this from the project root directory"
    exit 1
fi

# Check if Claude config exists
if [ ! -f "$CLAUDE_CONFIG_PATH" ]; then
    print_info "No existing Claude configuration found"
    print_info "Creating new configuration from template..."
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$CLAUDE_CONFIG_PATH")"
    
    # Copy template
    cp "$TEMPLATE_PATH" "$CLAUDE_CONFIG_PATH"
    print_success "New Claude configuration created at: $CLAUDE_CONFIG_PATH"
    exit 0
fi

print_info "Found existing Claude configuration: $CLAUDE_CONFIG_PATH"

# Backup existing config
BACKUP_PATH="${CLAUDE_CONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$CLAUDE_CONFIG_PATH" "$BACKUP_PATH"
print_success "Backup created: $BACKUP_PATH"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_error "jq is required for JSON manipulation"
    print_info "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

# Read existing config
EXISTING_CONFIG=$(cat "$CLAUDE_CONFIG_PATH")

# Read template
TEMPLATE_CONFIG=$(cat "$TEMPLATE_PATH")

# Extract lokka servers from template
LOKKA_DASEIN=$(echo "$TEMPLATE_CONFIG" | jq '.mcpServers."lokka-dasein"')
LOKKA_SPECTRAL=$(echo "$TEMPLATE_CONFIG" | jq '.mcpServers."lokka-spectral"')

# Check if lokka servers already exist
if echo "$EXISTING_CONFIG" | jq -e '.mcpServers."lokka-dasein"' > /dev/null 2>&1; then
    print_warning "lokka-dasein server already exists in configuration"
    read -p "Overwrite existing lokka-dasein configuration? (y/N): " overwrite_dasein
    if [[ ! $overwrite_dasein =~ ^[Yy]$ ]]; then
        print_info "Skipping lokka-dasein server"
        LOKKA_DASEIN="null"
    fi
fi

if echo "$EXISTING_CONFIG" | jq -e '.mcpServers."lokka-spectral"' > /dev/null 2>&1; then
    print_warning "lokka-spectral server already exists in configuration"
    read -p "Overwrite existing lokka-spectral configuration? (y/N): " overwrite_spectral
    if [[ ! $overwrite_spectral =~ ^[Yy]$ ]]; then
        print_info "Skipping lokka-spectral server"
        LOKKA_SPECTRAL="null"
    fi
fi

# Merge configurations
MERGED_CONFIG="$EXISTING_CONFIG"

if [ "$LOKKA_DASEIN" != "null" ]; then
    MERGED_CONFIG=$(echo "$MERGED_CONFIG" | jq --argjson server "$LOKKA_DASEIN" '.mcpServers."lokka-dasein" = $server')
    print_success "Added lokka-dasein server to configuration"
fi

if [ "$LOKKA_SPECTRAL" != "null" ]; then
    MERGED_CONFIG=$(echo "$MERGED_CONFIG" | jq --argjson server "$LOKKA_SPECTRAL" '.mcpServers."lokka-spectral" = $server')
    print_success "Added lokka-spectral server to configuration"
fi

# Write merged config
echo "$MERGED_CONFIG" | jq . > "$CLAUDE_CONFIG_PATH"

# Validate JSON syntax
if jq . "$CLAUDE_CONFIG_PATH" > /dev/null 2>&1; then
    print_success "Configuration merged successfully!"
else
    print_error "JSON syntax error in merged configuration"
    print_info "Restoring backup..."
    cp "$BACKUP_PATH" "$CLAUDE_CONFIG_PATH"
    exit 1
fi

echo ""
print_info "Configuration Summary:"
echo "├── Original config backed up to: $BACKUP_PATH"
echo "├── Merged config saved to: $CLAUDE_CONFIG_PATH"
echo "└── Added Lokka MCP servers for multi-tenant Azure management"

echo ""
print_warning "Important: Restart Claude Desktop for changes to take effect"

echo ""
print_info "To test the configuration:"
echo "1. Load environment: source scripts/utilities/load-env.sh"
echo "2. Start Claude Desktop from terminal: open -a 'Claude'"
echo "3. Test query: 'Show me organization details for both tenants'"

exit 0
