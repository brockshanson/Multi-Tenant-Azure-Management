# MCP-Only Setup Guide

This guide shows how to set up Azure authentication for Lokka MCP servers without requiring Azure CLI installation.

## Prerequisites

- Access to both Azure tenants (Dasein Research Group & Spectral Solutions)
- Global Administrator or Application Administrator role in both tenants
- Node.js installed (for Lokka MCP server)
- Web browser access to Azure Portal

**No Azure CLI Required!**

## Step 1: Create App Registration (Dasein Research Group)

### 1.1 Navigate to Azure Portal

1. Open [Azure Portal](https://portal.azure.com)
2. Sign in to the **Dasein Research Group** tenant
3. Navigate to **Azure Active Directory** → **App registrations**

### 1.2 Create New Registration

1. Click **"New registration"**
2. Fill in the details:
   - **Name:** `Multi-Tenant-MCP-Dasein`
   - **Supported account types:** `Accounts in this organizational directory only`
   - **Redirect URI:** Leave blank (not needed for service apps)
3. Click **"Register"**

### 1.3 Note the Application (Client) ID

1. On the app registration page, copy the **Application (client) ID**
2. This becomes your `AZURE_CLIENT_1_ID`
3. Also note the **Directory (tenant) ID** (should be `ef63f3e9-134f-428f-b601-1bfe781034f8`)

### 1.4 Create Client Secret

1. Go to **"Certificates & secrets"** in the left menu
2. Click **"New client secret"**
3. Add description: `MCP-Server-Secret`
4. Set expiration: `24 months`
5. Click **"Add"**
6. **IMMEDIATELY COPY** the secret value - you won't see it again!
7. This becomes your `AZURE_CLIENT_1_SECRET`

### 1.5 Set API Permissions

1. Go to **"API permissions"** in the left menu
2. Click **"Add a permission"**
3. Select **"Microsoft Graph"**
4. Choose **"Application permissions"**
5. Add these permissions:
   - `User.Read.All`
   - `Group.Read.All`
   - `Application.Read.All`
   - `Directory.Read.All`
   - `Policy.Read.All`
   - `AuditLog.Read.All`
   - `Reports.Read.All`
   - `DeviceManagementConfiguration.Read.All`
   - `DeviceManagementManagedDevices.Read.All`

### 1.6 Grant Admin Consent

1. Click **"Grant admin consent for [Tenant Name]"**
2. Confirm the consent
3. Verify all permissions show **"Granted"** status

## Step 2: Create App Registration (Spectral Solutions)

### 2.1 Switch Tenants

1. In Azure Portal, click your profile in top-right corner
2. Click **"Switch directory"**
3. Select the **Spectral Solutions** tenant
4. Navigate to **Azure Active Directory** → **App registrations**

### 2.2 Repeat Registration Process

1. Create new registration named: `Multi-Tenant-MCP-Spectral`
2. Note the **Application (client) ID** for `AZURE_CLIENT_2_ID`
3. Create client secret for `AZURE_CLIENT_2_SECRET`
4. Add identical API permissions as Step 1.5
5. Grant admin consent

## Step 3: Configure Local Environment

### 3.1 Create Environment File

```bash
# Copy template
cp config/templates/.env.template .env.local

# Set secure permissions
chmod 600 .env.local
```

### 3.2 Edit Environment File

Open `.env.local` and add your values:

```bash
# Azure Tenant 1 (Dasein Research Group)
AZURE_TENANT_1_ID=ef63f3e9-134f-428f-b601-1bfe781034f8
AZURE_CLIENT_1_ID=[YOUR_DASEIN_CLIENT_ID]
AZURE_CLIENT_1_SECRET=[YOUR_DASEIN_CLIENT_SECRET]

# Azure Tenant 2 (Spectral Solutions)
AZURE_TENANT_2_ID=049d5c8d-0cb4-4880-bc97-8a770b44be56
AZURE_CLIENT_2_ID=[YOUR_SPECTRAL_CLIENT_ID]
AZURE_CLIENT_2_SECRET=[YOUR_SPECTRAL_CLIENT_SECRET]

# Optional Configuration
MCP_LOG_LEVEL=INFO
AZURE_GRAPH_API_VERSION=v1.0
DEBUG_MODE=false
ENABLE_AUDIT_LOGGING=true
```

## Step 4: Install and Configure Lokka MCP

### 4.1 Install Lokka MCP Server

```bash
npm install -g lokka-mcp
```

### 4.2 Set Up MCP Configuration

```bash
# Copy MCP template
cp config/templates/mcp-servers-template.json ~/.mcp-config.json

# For Claude Desktop (macOS)
mkdir -p ~/Library/Application\ Support/Claude
cp config/templates/mcp-servers-template.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

## Step 5: Test MCP-Only Authentication

### 5.1 Load Environment

```bash
source scripts/utilities/load-env.sh
```

### 5.2 Test Lokka MCP Directly

```bash
# Test Dasein Research Group
lokka-mcp \
  --tenant-id $AZURE_TENANT_1_ID \
  --client-id $AZURE_CLIENT_1_ID \
  --client-secret $AZURE_CLIENT_1_SECRET \
  --scope "https://graph.microsoft.com/.default"
```

### 5.3 Start Your MCP Client

```bash
# Load environment first
source scripts/utilities/load-env.sh

# Start your MCP client
code .              # VS Code
open -a "Claude"    # Claude Desktop
```

### 5.4 Test Queries

Try these in your MCP client:

```
Show me the organization details for the Dasein Research Group tenant
```

```
List users in the Spectral Solutions tenant
```

## Step 6: Validation Script (MCP-Only)

Create a simple validation script without Azure CLI:

```bash
#!/bin/bash
# validate-mcp-auth.sh

source .env.local

echo "Testing Lokka MCP authentication..."

# Test tenant 1
echo "Testing Dasein Research Group..."
lokka-mcp --tenant-id $AZURE_TENANT_1_ID \
          --client-id $AZURE_CLIENT_1_ID \
          --client-secret $AZURE_CLIENT_1_SECRET \
          --scope "https://graph.microsoft.com/.default" \
          --test-auth

# Test tenant 2  
echo "Testing Spectral Solutions..."
lokka-mcp --tenant-id $AZURE_TENANT_2_ID \
          --client-id $AZURE_CLIENT_2_ID \
          --client-secret $AZURE_CLIENT_2_SECRET \
          --scope "https://graph.microsoft.com/.default" \
          --test-auth

echo "MCP authentication validation complete!"
```

## Benefits of This Approach

✅ **No Azure CLI dependency** - Only need Node.js and web browser
✅ **Pure MCP authentication** - All runtime auth through Lokka MCP
✅ **Simpler setup** - Fewer tools to install and manage
✅ **Azure Portal familiarity** - Most admins know the portal
✅ **Clear separation** - Setup vs runtime authentication paths
✅ **Better security** - Admin controls app registration directly

## Troubleshooting

### Issue: "Permission not granted"
- Verify admin consent was clicked in Azure Portal
- Check that all permissions show "Granted" status
- Wait up to 24 hours for permission propagation

### Issue: "Client secret invalid"
- Ensure secret was copied immediately after creation
- Check for extra spaces or characters in .env.local
- Regenerate secret if needed through Azure Portal

### Issue: "Lokka MCP not starting"
- Verify Node.js installation: `node --version`
- Install Lokka MCP globally: `npm install -g lokka-mcp`
- Check environment variables are loaded: `env | grep AZURE_`

## Next Steps

1. Test cross-tenant queries through your MCP client
2. Create user accounts using the [User Account Generation Prompt](../templates/user-account-generation-prompt.md)
3. Begin license optimization workflows

This approach provides clean separation between setup (Azure Portal) and runtime (MCP-only) authentication.
