# MCP Configuration Guide

This guide covers the configuration of Lokka MCP servers for multi-tenant Azure management.

## Overview

Model Context Protocol (MCP) servers enable AI models to interact with external systems securely. Lokka MCP provides Microsoft Graph API access through a standardized interface.

## Installation

### Prerequisites

- Node.js 18+ or Python 3.8+
- Azure CLI installed and configured
- Azure App Registrations for each tenant

### Install Lokka MCP

```bash
# Install via npm (recommended)
npm install -g lokka-mcp

# Or install via pip
pip install lokka-mcp
```

## Configuration

### Environment Setup

1. **Copy configuration template**
   ```bash
   cp config/templates/mcp-servers-template.json ~/.mcp/config.json
   ```

2. **Load environment variables**
   ```bash
   source scripts/utilities/load-env.sh
   ```

3. **Verify configuration**
   ```bash
   scripts/utilities/check-env.sh
   ```

### MCP Server Configuration

The configuration uses environment variables for security:

```json
{
  "mcpServers": {
    "lokka-dasein": {
      "command": "lokka",
      "args": [
        "--tenant-id", "${AZURE_TENANT_1_ID}",
        "--client-id", "${AZURE_CLIENT_1_ID}",
        "--client-secret", "${AZURE_CLIENT_1_SECRET}",
        "--scope", "https://graph.microsoft.com/.default"
      ],
      "env": {
        "LOKKA_LOG_LEVEL": "INFO"
      }
    },
    "lokka-spectral": {
      "command": "lokka",
      "args": [
        "--tenant-id", "${AZURE_TENANT_2_ID}",
        "--client-id", "${AZURE_CLIENT_2_ID}",
        "--client-secret", "${AZURE_CLIENT_2_SECRET}",
        "--scope", "https://graph.microsoft.com/.default"
      ],
      "env": {
        "LOKKA_LOG_LEVEL": "INFO"
      }
    }
  }
}
```

## Client Interface Setup

### VS Code Configuration

1. **Install Extensions**
   - Install recommended extensions from `.vscode/extensions.json`
   - Restart VS Code

2. **Configure MCP**
   - Open Command Palette (`Cmd+Shift+P`)
   - Run "MCP: Configure Servers"
   - Point to your config file

### Claude Desktop Configuration

1. **Edit Configuration**
   ```bash
   # macOS
   open ~/Library/Application\ Support/Claude/claude_desktop_config.json
   
   # Windows
   notepad %APPDATA%\Claude\claude_desktop_config.json
   ```

2. **Add MCP Servers**
   - Copy the mcpServers section from your template
   - Restart Claude Desktop

## Testing Connection

### Basic Connectivity Test

```bash
# Test Dasein tenant
lokka --tenant-id $AZURE_TENANT_1_ID --client-id $AZURE_CLIENT_1_ID --client-secret $AZURE_CLIENT_1_SECRET test-connection

# Test Spectral tenant  
lokka --tenant-id $AZURE_TENANT_2_ID --client-id $AZURE_CLIENT_2_ID --client-secret $AZURE_CLIENT_2_SECRET test-connection
```

### Verify Permissions

Test common API endpoints:

```bash
# List users
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://graph.microsoft.com/v1.0/users

# List groups
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://graph.microsoft.com/v1.0/groups

# Get organization details
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://graph.microsoft.com/v1.0/organization
```

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Verify client secret hasn't expired
   - Check tenant ID is correct
   - Ensure app registration has required permissions

2. **Permission Denied**
   - Review API permissions in Azure Portal
   - Grant admin consent for application permissions
   - Wait for permissions to propagate (up to 24 hours)

3. **Connection Timeout**
   - Check network connectivity
   - Verify proxy settings if applicable
   - Test with Azure CLI: `az login --tenant $AZURE_TENANT_1_ID`

### Debug Mode

Enable debug logging:

```bash
export LOKKA_LOG_LEVEL=DEBUG
export AZURE_CLI_TRACE=1
```

## Related Documentation

- [Secret Management Guide](secret-management.md)
- [Authentication Guide](authentication-guide.md)
- [Azure Prerequisites](azure-prerequisites.md)
