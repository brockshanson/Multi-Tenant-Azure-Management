# Secret Management Guide

This guide covers secure handling of Azure credentials, client secrets, and sensitive configuration for the multi-tenant management system.

## Overview

For local development and testing, we use a secure local secret management strategy:

1. **Local Environment Files** - `.env.local` files (git-ignored)
2. **Environment Variables** - Runtime secrets loaded into shell
3. **MCP Configuration** - Environment variable references in config files
4. **Secure File Permissions** - Restrict access to secret files

**Note**: This guide focuses on local development. For production environments, consider Azure Key Vault or other enterprise secret management solutions.

## Environment Variables

### Required Environment Variables

```bash
# Azure Tenant 1 (Dasein Research Group)
export AZURE_TENANT_1_ID="ef63f3e9-134f-428f-b601-1bfe781034f8"
export AZURE_CLIENT_1_ID="16554e45-c734-480d-bb04-9f9fe7a3ab5e"
export AZURE_CLIENT_1_SECRET="[SECURE_SECRET]"

# Azure Tenant 2 (Spectral Solutions)
export AZURE_TENANT_2_ID="049d5c8d-0cb4-4880-bc97-8a770b44be56"
export AZURE_CLIENT_2_ID="15315bba-3aa4-46c6-be01-955198f119e0"
export AZURE_CLIENT_2_SECRET="[SECURE_SECRET]"

# Optional: Logging and debugging
export MCP_LOG_LEVEL="INFO"
export AZURE_GRAPH_API_VERSION="v1.0"
```

## Local Environment Setup

### Step 1: Create Local Environment File

1. **Copy the template**
   ```bash
   cp config/templates/.env.template .env.local
   ```

2. **Set secure file permissions**
   ```bash
   chmod 600 .env.local
   ```

3. **Edit with your actual credentials**
   ```bash
   # Use your preferred editor
   code .env.local
   # or
   nano .env.local
   ```

### Step 2: Configure Azure Credentials

Replace the placeholder values in `.env.local` with your actual Azure credentials:

```bash
# Azure Tenant 1 (Dasein Research Group)
AZURE_TENANT_1_ID=ef63f3e9-134f-428f-b601-1bfe781034f8
AZURE_CLIENT_1_ID=16554e45-c734-480d-bb04-9f9fe7a3ab5e
AZURE_CLIENT_1_SECRET=your_actual_client_secret_here

# Azure Tenant 2 (Spectral Solutions)
AZURE_TENANT_2_ID=049d5c8d-0cb4-4880-bc97-8a770b44be56
AZURE_CLIENT_2_ID=15315bba-3aa4-46c6-be01-955198f119e0
AZURE_CLIENT_2_SECRET=your_actual_client_secret_here

# Optional Configuration
MCP_LOG_LEVEL=INFO
AZURE_GRAPH_API_VERSION=v1.0
DEBUG_MODE=false
ENABLE_AUDIT_LOGGING=true
```

### Step 3: Load Environment Variables

Load the credentials into your current shell session:

```bash
source scripts/utilities/load-env.sh
```

### Step 4: Verify Configuration

Check that all required variables are set:

```bash
scripts/utilities/check-env.sh
```

## Lokka MCP Server Configuration

### Local MCP Configuration File

The Lokka MCP server reads credentials from environment variables. Here's how to set it up:

### Step 1: Create MCP Configuration

1. **Create your local MCP config**
   ```bash
   cp config/templates/mcp-servers-template.json ~/.mcp-config.json
   ```

2. **For Claude Desktop users**
   ```bash
   # macOS
   cp config/templates/mcp-servers-template.json ~/Library/Application\ Support/Claude/claude_desktop_config.json
   
   # Windows  
   cp config/templates/mcp-servers-template.json %APPDATA%\Claude\claude_desktop_config.json
   ```

### Step 2: Understand Environment Variable Substitution

The configuration uses environment variables for security:

```json
{
  "mcpServers": {
    "lokka-dasein": {
      "command": "lokka-mcp",
      "args": [
        "--tenant-id", "${AZURE_TENANT_1_ID}",
        "--client-id", "${AZURE_CLIENT_1_ID}",
        "--client-secret", "${AZURE_CLIENT_1_SECRET}",
        "--scope", "https://graph.microsoft.com/.default"
      ],
      "env": {
        "LOKKA_LOG_LEVEL": "${MCP_LOG_LEVEL:-INFO}"
      }
    },
    "lokka-spectral": {
      "command": "lokka-mcp",
      "args": [
        "--tenant-id", "${AZURE_TENANT_2_ID}",
        "--client-id", "${AZURE_CLIENT_2_ID}",
        "--client-secret", "${AZURE_CLIENT_2_SECRET}",
        "--scope", "https://graph.microsoft.com/.default"
      ],
      "env": {
        "LOKKA_LOG_LEVEL": "${MCP_LOG_LEVEL:-INFO}"
      }
    }
  }
}
```

### Step 3: Start Your Client with Environment Variables

**For Claude Desktop:**
```bash
# Load environment variables first
source scripts/utilities/load-env.sh

# Start Claude Desktop from terminal (so it inherits env vars)
open -a "Claude"  # macOS
# or start from Applications menu after setting system env vars
```

**For VS Code:**
```bash
# Load environment variables
source scripts/utilities/load-env.sh

# Start VS Code from terminal
code .
```

**For Custom Clients:**
```bash
# Environment variables are already loaded and available to any process
# started from this terminal session
```

## Testing Your Local Setup

### Verify Environment Variables Are Loaded

```bash
# Check that variables are set (without exposing values)
scripts/utilities/check-env.sh

# Test specific variable (shows first 8 characters only)
echo "Tenant 1 ID: ${AZURE_TENANT_1_ID:0:8}..."
echo "Client 1 ID: ${AZURE_CLIENT_1_ID:0:8}..."
```

### Test Azure Authentication

```bash
# Test authentication using Azure CLI
az login --service-principal \
  --username $AZURE_CLIENT_1_ID \
  --password $AZURE_CLIENT_1_SECRET \
  --tenant $AZURE_TENANT_1_ID

# Verify access to Graph API
az rest --method GET --uri "https://graph.microsoft.com/v1.0/me" || \
az rest --method GET --uri "https://graph.microsoft.com/v1.0/organization"
```

### Test MCP Server Connectivity

If you have Lokka MCP installed locally:

```bash
# Test direct connection
lokka-mcp --tenant-id $AZURE_TENANT_1_ID \
          --client-id $AZURE_CLIENT_1_ID \
          --client-secret $AZURE_CLIENT_1_SECRET \
          --test-connection

# Or test with a simple query
lokka-mcp --tenant-id $AZURE_TENANT_1_ID \
          --client-id $AZURE_CLIENT_1_ID \
          --client-secret $AZURE_CLIENT_1_SECRET \
          --query "organization"
```

## Security Best Practices

### Git Security

- ✅ All `.env*` files are git-ignored
- ✅ Client secrets never committed to version control
- ✅ Configuration templates use placeholder values
- ✅ Actual secrets stored outside repository

### Credential Rotation

```bash
# Regular rotation script
./scripts/utilities/rotate-credentials.sh

# Test new credentials
./scripts/utilities/test-connectivity.sh
```

### Access Auditing

- All secret access logged
- Regular credential usage reviews
- Automated secret expiration alerts
- Multi-factor authentication required

## Troubleshooting

### Common Issues

1. **Environment Variables Not Loaded**
   ```bash
   # Check if variables are set
   ./scripts/utilities/check-env.sh
   ```

2. **MCP Authentication Failures**
   ```bash
   # Test authentication separately
   ./scripts/utilities/test-auth.sh
   ```

3. **Secret Rotation Required**
   ```bash
   # Generate new client secrets
   ./scripts/utilities/rotate-credentials.sh
   ```

## Related Documentation

- [MCP Configuration Guide](mcp-configuration.md)
- [Authentication Guide](authentication-guide.md)
- [Troubleshooting Guide](troubleshooting.md)
