# Troubleshooting Guide

This guide helps resolve common issues with Azure multi-tenant management and Lokka MCP server setup.

## Quick Diagnostics

Run these commands to quickly identify issues:

```bash
# Check environment configuration
./scripts/utilities/check-env.sh

# Test authentication
./scripts/utilities/check-env.sh --test-auth

# Check Azure CLI status
az account show
```

## Common Issues and Solutions

### Environment Variables

#### Issue: "Environment file .env.local not found"

**Cause:** The local environment file hasn't been created.

**Solution:**
```bash
# Option 1: Use automated setup
./scripts/utilities/setup-azure-credentials.sh

# Option 2: Manual setup
cp config/templates/.env.template .env.local
chmod 600 .env.local
# Edit .env.local with your credentials
```

#### Issue: "Missing required environment variables"

**Cause:** Environment variables aren't loaded or .env.local is incomplete.

**Solution:**
```bash
# Load environment variables
source scripts/utilities/load-env.sh

# Check what's missing
./scripts/utilities/check-env.sh

# If .env.local is incomplete, edit it:
code .env.local
```

#### Issue: "Insecure file permissions on .env.local"

**Cause:** The .env.local file has overly permissive file permissions.

**Solution:**
```bash
# Fix permissions (owner read/write only)
chmod 600 .env.local

# Verify permissions
ls -la .env.local
```

### Azure Authentication

#### Issue: "AADSTS7000215: Invalid client secret is provided"

**Cause:** Client secret is incorrect, expired, or not properly copied.

**Solution:**
```bash
# Check if secret expired
az ad app credential list --id $AZURE_CLIENT_1_ID

# Generate new secret
NEW_SECRET=$(az ad app credential reset --id $AZURE_CLIENT_1_ID --years 2 --query "password" -o tsv)

# Update .env.local with new secret
sed -i '' "s/AZURE_CLIENT_1_SECRET=.*/AZURE_CLIENT_1_SECRET=$NEW_SECRET/" .env.local

# Reload environment
source scripts/utilities/load-env.sh
```

#### Issue: "AADSTS90002: Tenant 'xxx' not found"

**Cause:** Tenant ID is incorrect or the tenant doesn't exist.

**Solution:**
```bash
# Verify tenant IDs in .env.local
cat .env.local | grep TENANT

# Expected values:
# AZURE_TENANT_1_ID=ef63f3e9-134f-428f-b601-1bfe781034f8  (Dasein Research Group)
# AZURE_TENANT_2_ID=049d5c8d-0cb4-4880-bc97-8a770b44be56  (Spectral Solutions)
```

#### Issue: "Insufficient privileges to complete the operation"

**Cause:** App registration lacks required permissions or admin consent wasn't granted.

**Solution:**
```bash
# Check current permissions
az ad app permission list --id $AZURE_CLIENT_1_ID

# Re-grant admin consent
az ad app permission admin-consent --id $AZURE_CLIENT_1_ID

# Wait up to 24 hours for permission propagation
```

#### Issue: "Authentication successful but Graph API access failed"

**Cause:** Permissions are granted but not yet propagated throughout Azure.

**Solution:**
```bash
# Wait for permission propagation (can take up to 24 hours)
# Test direct Graph API access:
TOKEN=$(az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)
curl -H "Authorization: Bearer $TOKEN" "https://graph.microsoft.com/v1.0/users?$top=1"
```

### MCP Server Issues

#### Issue: "MCP server not starting" or "Command not found: lokka-mcp"

**Cause:** Lokka MCP server is not installed or not in PATH.

**Solution:**
```bash
# Install globally
npm install -g lokka-mcp

# Verify installation
lokka-mcp --version

# Test manual startup
lokka-mcp --tenant-id $AZURE_TENANT_1_ID --client-id $AZURE_CLIENT_1_ID --client-secret $AZURE_CLIENT_1_SECRET --scope "https://graph.microsoft.com/.default"
```

#### Issue: "MCP configuration file not found"

**Cause:** MCP configuration file is missing or in wrong location.

**Solution:**
```bash
# Copy template to standard location
cp config/templates/mcp-servers-template.json ~/.mcp-config.json

# For Claude Desktop (macOS)
mkdir -p ~/Library/Application\ Support/Claude
cp config/templates/mcp-servers-template.json ~/Library/Application\ Support/Claude/claude_desktop_config.json

# For Claude Desktop (Windows)
mkdir -p "$APPDATA/Claude"
cp config/templates/mcp-servers-template.json "$APPDATA/Claude/claude_desktop_config.json"
```

#### Issue: "Environment variable substitution not working in MCP config"

**Cause:** MCP client isn't inheriting environment variables.

**Solution:**
```bash
# Always start MCP client from terminal with loaded environment
source scripts/utilities/load-env.sh

# Then start your client from the same terminal:
code .              # VS Code
open -a "Claude"    # Claude Desktop

# Verify environment inheritance:
env | grep AZURE_
```

### Client-Specific Issues

#### Issue: "VS Code not recognizing MCP servers"

**Cause:** VS Code MCP extension not installed or configured.

**Solution:**
```bash
# Install required extensions
code --install-extension ms-vscode.vscode-json
code --install-extension ms-vscode.vscode-typescript-next

# Check if MCP extension is available and install if needed
# Ensure .vscode/settings.json includes MCP configuration
```

#### Issue: "Claude Desktop not connecting to MCP servers"

**Cause:** Configuration file location or format issues.

**Solution:**
```bash
# Verify configuration file location
ls -la ~/Library/Application\ Support/Claude/claude_desktop_config.json  # macOS
ls -la "$APPDATA/Claude/claude_desktop_config.json"                     # Windows

# Check JSON syntax
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | jq .

# Restart Claude Desktop after changes
```

### Azure CLI Issues

#### Issue: "Azure CLI not found" or version issues

**Cause:** Azure CLI not installed or outdated.

**Solution:**
```bash
# Install Azure CLI (macOS)
brew install azure-cli

# Install Azure CLI (Windows)
# Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows

# Update to latest version
az upgrade

# Verify installation
az --version
```

#### Issue: "Multiple Azure CLI sessions conflicting"

**Cause:** Multiple login sessions or cached credentials interfering.

**Solution:**
```bash
# Clear all cached credentials
az account clear

# Login to specific tenant
az login --tenant $AZURE_TENANT_1_ID

# Verify correct tenant
az account show --query "{tenantId: tenantId, name: name}"
```

### Permission and Access Issues

#### Issue: "Admin consent required but can't grant"

**Cause:** Insufficient privileges in the Azure tenant.

**Solution:**
```bash
# Check your role in the tenant
az rest --method GET --uri "https://graph.microsoft.com/v1.0/me/memberOf"

# You need one of these roles:
# - Global Administrator
# - Application Administrator  
# - Cloud Application Administrator

# Contact your tenant administrator if you lack required roles
```

#### Issue: "App registration creation failed"

**Cause:** Insufficient permissions to create app registrations.

**Solution:**
```bash
# Check if you can create apps
az ad app list --query "length(@)"

# If this fails, you need "Application Developer" role or higher
# Contact your tenant administrator
```

### Network and Connectivity Issues

#### Issue: "Network timeouts or connection failures"

**Cause:** Network restrictions, proxies, or firewall blocking Azure APIs.

**Solution:**
```bash
# Test basic connectivity
curl -I https://graph.microsoft.com

# Test Azure endpoints
curl -I https://login.microsoftonline.com

# If behind corporate proxy, configure:
az config set core.proxy_server=http://proxy.company.com:8080
```

#### Issue: "SSL/TLS certificate errors"

**Cause:** Corporate proxy or network intercepting SSL certificates.

**Solution:**
```bash
# Disable SSL verification (temporary, not recommended for production)
az config set core.disable_ssl_verify=true

# Or configure proper certificates for your environment
# Contact your IT administrator for corporate CA certificates
```

### File System Issues

#### Issue: "Permission denied when accessing files"

**Cause:** Incorrect file permissions or ownership.

**Solution:**
```bash
# Fix ownership of workspace
sudo chown -R $USER:$USER .

# Fix script permissions
chmod +x scripts/utilities/*.sh

# Fix .env.local permissions
chmod 600 .env.local
```

#### Issue: "Scripts won't execute" or "Permission denied"

**Cause:** Scripts don't have execute permissions.

**Solution:**
```bash
# Make all utility scripts executable
chmod +x scripts/utilities/*.sh

# Verify permissions
ls -la scripts/utilities/
```

## Advanced Debugging

### Enable Debug Logging

```bash
# Azure CLI debug mode
az config set core.debug=true

# Enable Lokka MCP debug logging
export MCP_LOG_LEVEL=DEBUG

# Enable Azure PowerShell debug (if using)
$DebugPreference = "Continue"
```

### Detailed Log Analysis

```bash
# Check Azure CLI logs
cat ~/.azure/logs/az.log

# Check system logs for authentication issues
# macOS:
log show --predicate 'process CONTAINS "az"' --last 1h

# Linux:
journalctl -u azure-cli --since "1 hour ago"
```

### Manual Graph API Testing

```bash
# Get access token manually
TOKEN=$(az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)

# Test basic Graph API access
curl -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     "https://graph.microsoft.com/v1.0/me"

# Test specific endpoints
curl -H "Authorization: Bearer $TOKEN" \
     "https://graph.microsoft.com/v1.0/users?$top=5"
```

## Getting Help

### Check Documentation

1. [Local Credential Setup Walkthrough](local-credential-setup-walkthrough.md)
2. [Tenant Setup Guide](tenant-setup-guide.md)
3. [Authentication Guide](../references/authentication-guide.md)
4. [Secret Management Guide](../references/secret-management.md)

### Log Collection for Support

```bash
# Collect diagnostic information
./scripts/utilities/check-env.sh --test-auth > debug.log 2>&1
az --version >> debug.log
node --version >> debug.log
lokka-mcp --version >> debug.log 2>&1 || echo "lokka-mcp not installed" >> debug.log

# Check file (ensure no secrets are included before sharing)
cat debug.log
```

### Reset Everything (Nuclear Option)

```bash
# Clear all Azure CLI sessions
az account clear

# Remove environment file
rm .env.local

# Remove MCP configurations
rm ~/.mcp-config.json
rm ~/Library/Application\ Support/Claude/claude_desktop_config.json 2>/dev/null || true

# Start fresh with automated setup
./scripts/utilities/setup-azure-credentials.sh
```

## Common Error Codes

| Error Code | Description | Solution |
|------------|-------------|----------|
| AADSTS7000215 | Invalid client secret | Regenerate client secret |
| AADSTS90002 | Tenant not found | Verify tenant ID |
| AADSTS65001 | User or admin has not consented | Grant admin consent |
| AADSTS50020 | User account from external provider | Use work/school account |
| AADSTS700016 | Application not found | Verify client ID |
| AADSTS700051 | Response_type is not supported | Check redirect URI configuration |

## Prevention Tips

1. **Set Calendar Reminders** - Client secrets expire in 24 months
2. **Regular Testing** - Run `./scripts/utilities/check-env.sh --test-auth` weekly
3. **Backup Configurations** - Keep secure backups of working .env.local files
4. **Document Changes** - Log any configuration changes in workflow files
5. **Monitor Permissions** - Regular audit of app registration permissions

For additional support, refer to the main documentation or create an issue in the repository.
