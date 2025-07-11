# Tenant Setup Guide

This guide walks you through the complete process of setting up Azure tenant authentication for the Lokka MCP servers.

## Prerequisites

- Azure subscription access for both test tenants
- Azure CLI installed (`az --version`)
- Appropriate permissions to create app registrations
- GitHub CLI configured (`gh auth status`)

## Overview

You'll create Azure App Registrations for each tenant that allow the Lokka MCP servers to authenticate and access Microsoft Graph APIs.

## Step 1: Azure App Registration (Tenant 1 - Dasein Research Group)

### 1.1 Login to Dasein Research Group Tenant

```bash
# Login to the first tenant
az login --tenant ef63f3e9-134f-428f-b601-1bfe781034f8

# Verify you're in the correct tenant
az account show --query "{tenantId: tenantId, name: name}"
```

### 1.2 Create App Registration

```bash
# Create the app registration
az ad app create \
  --display-name "Multi-Tenant-MCP-Dasein" \
  --sign-in-audience "AzureADMyOrg"

# Note the appId from the output - this becomes your AZURE_CLIENT_1_ID
```

### 1.3 Create Service Principal

```bash
# Create service principal (replace APP_ID with the appId from previous step)
APP_ID="your-app-id-here"
az ad sp create --id $APP_ID

# Get the service principal object ID for later use
SP_OBJECT_ID=$(az ad sp show --id $APP_ID --query "id" -o tsv)
echo "Service Principal Object ID: $SP_OBJECT_ID"
```

### 1.4 Generate Client Secret

```bash
# Create client secret (valid for 24 months)
CLIENT_SECRET=$(az ad app credential reset --id $APP_ID --years 2 --query "password" -o tsv)
echo "Client Secret: $CLIENT_SECRET"

# IMPORTANT: Save this secret immediately - you won't see it again!
```

### 1.5 Grant API Permissions

```bash
# Add Microsoft Graph permissions
az ad app permission add --id $APP_ID --api 00000003-0000-0000-c000-000000000000 --api-permissions \
  df021288-bdef-4463-88db-98f22de89214=Role \
  b0afded3-3588-46d8-8b3d-9842eff778da=Role \
  9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30=Role \
  230c1aed-a721-4c5d-9cb4-a90514e508ef=Role \
  246dd0d5-5bd0-4def-940b-0421030a5b68=Role \
  b633e1c5-b582-4048-a93e-9f11b44c7e96=Role \
  02e97553-ed7b-43d0-ab3c-f8bace0d040c=Role \
  2f51be20-0bb4-4fed-bf7b-db946066c75e=Role \
  5ac13192-7ace-4fcf-b828-1a26f28068ee=Role

# Grant admin consent
az ad app permission admin-consent --id $APP_ID

# Verify permissions were granted
az ad app permission list --id $APP_ID --query "[].{resource:resourceDisplayName, permission:permission}" -o table
```

## Step 2: Azure App Registration (Tenant 2 - Spectral Solutions)

### 2.1 Login to Spectral Solutions Tenant

```bash
# Login to the second tenant
az login --tenant 049d5c8d-0cb4-4880-bc97-8a770b44be56

# Verify you're in the correct tenant
az account show --query "{tenantId: tenantId, name: name}"
```

### 2.2 Repeat App Registration Process

```bash
# Create the app registration for Spectral Solutions
az ad app create \
  --display-name "Multi-Tenant-MCP-Spectral" \
  --sign-in-audience "AzureADMyOrg"

# Note the appId - this becomes your AZURE_CLIENT_2_ID
APP_ID_2="your-second-app-id-here"

# Create service principal
az ad sp create --id $APP_ID_2

# Generate client secret
CLIENT_SECRET_2=$(az ad app credential reset --id $APP_ID_2 --years 2 --query "password" -o tsv)
echo "Client Secret 2: $CLIENT_SECRET_2"

# Add same API permissions as tenant 1
az ad app permission add --id $APP_ID_2 --api 00000003-0000-0000-c000-000000000000 --api-permissions \
  df021288-bdef-4463-88db-98f22de89214=Role \
  b0afded3-3588-46d8-8b3d-9842eff778da=Role \
  9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30=Role \
  230c1aed-a721-4c5d-9cb4-a90514e508ef=Role \
  246dd0d5-5bd0-4def-940b-0421030a5b68=Role \
  b633e1c5-b582-4048-a93e-9f11b44c7e96=Role \
  02e97553-ed7b-43d0-ab3c-f8bace0d040c=Role \
  2f51be20-0bb4-4fed-bf7b-db946066c75e=Role \
  5ac13192-7ace-4fcf-b828-1a26f28068ee=Role

# Grant admin consent
az ad app permission admin-consent --id $APP_ID_2
```

## Step 3: Configure Local Environment

### 3.1 Create Local Environment File

```bash
# Copy template
cp config/templates/.env.template .env.local

# Set secure permissions
chmod 600 .env.local
```

### 3.2 Update Environment File

Edit `.env.local` with your actual values:

```bash
# Azure Tenant 1 (Dasein Research Group)
AZURE_TENANT_1_ID=ef63f3e9-134f-428f-b601-1bfe781034f8
AZURE_CLIENT_1_ID=your-actual-app-id-1-here
AZURE_CLIENT_1_SECRET=your-actual-client-secret-1-here

# Azure Tenant 2 (Spectral Solutions)
AZURE_TENANT_2_ID=049d5c8d-0cb4-4880-bc97-8a770b44be56
AZURE_CLIENT_2_ID=your-actual-app-id-2-here
AZURE_CLIENT_2_SECRET=your-actual-client-secret-2-here

# Optional Configuration
MCP_LOG_LEVEL=INFO
AZURE_GRAPH_API_VERSION=v1.0
DEBUG_MODE=false
ENABLE_AUDIT_LOGGING=true
```

### 3.3 Load and Test Environment

```bash
# Load environment variables
source scripts/utilities/load-env.sh

# Verify all variables are set
scripts/utilities/check-env.sh

# Test authentication for both tenants
az login --service-principal --username $AZURE_CLIENT_1_ID --password $AZURE_CLIENT_1_SECRET --tenant $AZURE_TENANT_1_ID
az rest --method GET --uri "https://graph.microsoft.com/v1.0/organization"

az login --service-principal --username $AZURE_CLIENT_2_ID --password $AZURE_CLIENT_2_SECRET --tenant $AZURE_TENANT_2_ID  
az rest --method GET --uri "https://graph.microsoft.com/v1.0/organization"
```

## Step 4: Configure MCP Servers

### 4.1 Set Up MCP Configuration

```bash
# For VS Code or general use
cp config/templates/mcp-servers-template.json ~/.mcp-config.json

# For Claude Desktop (macOS)
cp config/templates/mcp-servers-template.json ~/Library/Application\ Support/Claude/claude_desktop_config.json

# For Claude Desktop (Windows)
cp config/templates/mcp-servers-template.json %APPDATA%\Claude\claude_desktop_config.json
```

### 4.2 Start Your Client

**For Claude Desktop:**
```bash
# Load environment variables first
source scripts/utilities/load-env.sh

# Start Claude Desktop from terminal (inherits environment)
open -a "Claude"  # macOS
```

**For VS Code:**
```bash
# Load environment variables
source scripts/utilities/load-env.sh

# Start VS Code from same terminal
code .
```

## Step 5: Verify Everything Works

### 5.1 Test MCP Connection

In your chosen client interface, try these queries:

```
Show me the organization details for the Dasein Research Group tenant
```

```
List the first 5 users in the Spectral Solutions tenant
```

```
Compare the number of users between both tenants
```

### 5.2 Troubleshooting

If you encounter issues:

1. **Check environment variables are loaded**
   ```bash
   scripts/utilities/check-env.sh
   ```

2. **Verify Azure authentication**
   ```bash
   az login --service-principal --username $AZURE_CLIENT_1_ID --password $AZURE_CLIENT_1_SECRET --tenant $AZURE_TENANT_1_ID
   ```

3. **Check API permissions**
   ```bash
   az ad app permission list --id $AZURE_CLIENT_1_ID
   ```

4. **Test Graph API directly**
   ```bash
   TOKEN=$(az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)
   curl -H "Authorization: Bearer $TOKEN" "https://graph.microsoft.com/v1.0/users?$top=1"
   ```

## Permission Reference

The following Microsoft Graph API permissions are granted to each app registration:

| Permission | Type | Description |
|------------|------|-------------|
| `User.Read.All` | Application | Read all users' profiles |
| `Group.Read.All` | Application | Read all groups |
| `Application.Read.All` | Application | Read all applications |
| `Directory.Read.All` | Application | Read directory data |
| `Policy.Read.All` | Application | Read all policies |
| `AuditLog.Read.All` | Application | Read audit logs |
| `Reports.Read.All` | Application | Read usage reports |
| `DeviceManagementConfiguration.Read.All` | Application | Read Intune configuration |
| `DeviceManagementManagedDevices.Read.All` | Application | Read managed devices |

## Security Notes

- Client secrets are valid for 24 months
- Set calendar reminders to rotate secrets before expiration
- Never commit actual secrets to version control
- Use secure file permissions (600) on .env.local
- Regularly audit app registration permissions

## Next Steps

Once authentication is working:

1. Create test user accounts using the [User Account Generation Prompt](../templates/user-account-generation-prompt.md)
2. Start logging your interactions using [Workflow Templates](../../workflows/templates/)
3. Begin license optimization testing and cross-tenant analysis

## Related Documentation

- [Secret Management Guide](../references/secret-management.md)
- [Authentication Guide](../references/authentication-guide.md)
- [MCP Configuration Guide](../references/mcp-configuration.md)
