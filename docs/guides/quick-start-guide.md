# Quick Start Guide

This guide will get you up and running with Azure multi-tenant management via Lokka MCP servers in under 15 minutes.

## One-Command Setup

For a fully automated setup, run:

```bash
./scripts/utilities/setup-azure-credentials.sh
```

This script will:
- ✅ Check all prerequisites
- ✅ Create Azure app registrations for both tenants
- ✅ Generate client secrets with proper permissions
- ✅ Create a secure `.env.local` file
- ✅ Set up MCP configuration
- ✅ Test authentication for both tenants

## Manual Setup (Alternative)

If you prefer manual setup or need to troubleshoot:

### 1. Prerequisites Check

```bash
# Check Azure CLI
az --version

# Check Node.js
node --version

# Install jq if needed (macOS)
brew install jq
```

### 2. Create App Registrations

**Dasein Research Group:**
```bash
az login --tenant ef63f3e9-134f-428f-b601-1bfe781034f8
DASEIN_APP=$(az ad app create --display-name "Multi-Tenant-MCP-Dasein" --sign-in-audience "AzureADMyOrg" --query "appId" -o tsv)
DASEIN_SECRET=$(az ad app credential reset --id $DASEIN_APP --years 2 --query "password" -o tsv)
```

**Spectral Solutions:**
```bash
az login --tenant 049d5c8d-0cb4-4880-bc97-8a770b44be56
SPECTRAL_APP=$(az ad app create --display-name "Multi-Tenant-MCP-Spectral" --sign-in-audience "AzureADMyOrg" --query "appId" -o tsv)
SPECTRAL_SECRET=$(az ad app credential reset --id $SPECTRAL_APP --years 2 --query "password" -o tsv)
```

### 3. Configure Local Environment

```bash
# Copy template and set permissions
cp config/templates/.env.template .env.local
chmod 600 .env.local

# Edit with your values
code .env.local
```

### 4. Load and Test

```bash
# Load environment variables
source scripts/utilities/load-env.sh

# Test authentication
./scripts/utilities/check-env.sh --test-auth
```

## Start Using MCP

### Load Environment and Start Client

```bash
# Always load environment first
source scripts/utilities/load-env.sh

# Start your MCP client (VS Code, Claude Desktop, etc.)
code .  # For VS Code
# or
open -a "Claude"  # For Claude Desktop
```

### Test Queries

Try these in your MCP client:

```
Show me the organization details for both tenants
```

```
List the first 5 users in each tenant
```

```
Compare license allocation between Dasein Research Group and Spectral Solutions
```

## Common Commands

```bash
# Check environment variables
./scripts/utilities/check-env.sh

# Test authentication  
./scripts/utilities/check-env.sh --test-auth

# Load environment
source scripts/utilities/load-env.sh

# Full setup from scratch
./scripts/utilities/setup-azure-credentials.sh
```

## Troubleshooting

### Issue: "Environment variables not found"
```bash
source scripts/utilities/load-env.sh
```

### Issue: "Authentication failed"
```bash
# Check if secrets expired or wrong
./scripts/utilities/check-env.sh --test-auth

# Regenerate if needed
az ad app credential reset --id $AZURE_CLIENT_1_ID --years 2
```

### Issue: "Insufficient privileges"
```bash
# Re-grant admin consent
az ad app permission admin-consent --id $AZURE_CLIENT_1_ID
```

### Issue: "MCP server not starting"
```bash
# Test Lokka MCP manually
lokka-mcp --tenant-id $AZURE_TENANT_1_ID --client-id $AZURE_CLIENT_1_ID --client-secret $AZURE_CLIENT_1_SECRET --scope "https://graph.microsoft.com/.default"
```

## Next Steps

1. **Create test users** - Follow [User Account Generation Prompt](templates/user-account-generation-prompt.md)
2. **Start logging** - Use [Command Log Templates](../../workflows/templates/command-log-template.md)
3. **License optimization** - Follow [Multi-Tenant Management Guide](multi-tenant-management-guide.md)

## File Structure

```
.env.local                                    # Your secrets (git-ignored)
~/.mcp-config.json                           # MCP configuration
config/templates/mcp-servers-template.json   # MCP template
scripts/utilities/setup-azure-credentials.sh # Automated setup
scripts/utilities/load-env.sh                # Load environment
scripts/utilities/check-env.sh               # Check & test
```

## Security Reminders

- ✅ `.env.local` has 600 permissions (owner only)
- ✅ Secrets are not committed to git
- ✅ Client secrets expire in 24 months (set calendar reminder)
- ✅ App registrations have minimal required permissions

## Support

For detailed instructions, see:
- [Local Credential Setup Walkthrough](local-credential-setup-walkthrough.md)
- [Tenant Setup Guide](tenant-setup-guide.md)
- [Authentication Guide](../references/authentication-guide.md)
