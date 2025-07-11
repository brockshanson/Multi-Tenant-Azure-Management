#!/bin/bash

# Helper script to create Azure app registrations and extract the required information

echo "🔧 Azure App Registration Helper"
echo "================================"

# Check if user is logged in to Azure CLI
if ! az account show >/dev/null 2>&1; then
    echo "❌ Please login to Azure CLI first: az login"
    exit 1
fi

echo "📋 Current Azure Context:"
az account show --query "{tenantId: tenantId, name: name, user: user.name}" -o table

echo ""
read -p "Is this the correct tenant for your app registration? (y/n): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo "Please switch to the correct tenant first:"
    echo "  az login --tenant YOUR_TENANT_ID"
    exit 1
fi

echo ""
read -p "Enter a name for your app registration (e.g., Multi-Tenant-MCP-Dasein): " app_name

if [[ -z "$app_name" ]]; then
    echo "❌ App name cannot be empty"
    exit 1
fi

echo ""
echo "🔨 Creating app registration..."

# Create the app registration
app_info=$(az ad app create --display-name "$app_name" --sign-in-audience "AzureADMyOrg" 2>/dev/null)

if [[ $? -ne 0 ]]; then
    echo "❌ Failed to create app registration. Please check your permissions."
    exit 1
fi

app_id=$(echo "$app_info" | jq -r '.appId')
echo "✅ App registration created: $app_id"

echo ""
echo "🔨 Creating service principal..."
az ad sp create --id "$app_id" >/dev/null 2>&1

echo ""
echo "🔨 Generating client secret..."
client_secret=$(az ad app credential reset --id "$app_id" --years 2 --query "password" -o tsv 2>/dev/null)

if [[ $? -ne 0 ]]; then
    echo "❌ Failed to create client secret"
    exit 1
fi

echo ""
echo "🔨 Adding Microsoft Graph API permissions..."

# Add required permissions
permissions=(
    "df021288-bdef-4463-88db-98f22de89214=Role"  # User.Read.All
    "b0afded3-3588-46d8-8b3d-9842eff778da=Role"  # Group.Read.All  
    "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30=Role"  # Application.Read.All
    "230c1aed-a721-4c5d-9cb4-a90514e508ef=Role"  # Directory.Read.All
    "246dd0d5-5bd0-4def-940b-0421030a5b68=Role"  # Policy.Read.All
    "b633e1c5-b582-4048-a93e-9f11b44c7e96=Role"  # AuditLog.Read.All
    "02e97553-ed7b-43d0-ab3c-f8bace0d040c=Role"  # Reports.Read.All
    "2f51be20-0bb4-4fed-bf7b-db946066c75e=Role"  # DeviceManagementConfiguration.Read.All
    "5ac13192-7ace-4fcf-b828-1a26f28068ee=Role"  # DeviceManagementManagedDevices.Read.All
)

for permission in "${permissions[@]}"; do
    az ad app permission add --id "$app_id" --api 00000003-0000-0000-c000-000000000000 --api-permissions "$permission" >/dev/null 2>&1
done

echo ""
echo "🔨 Granting admin consent..."
az ad app permission admin-consent --id "$app_id" >/dev/null 2>&1

tenant_id=$(az account show --query "tenantId" -o tsv)

echo ""
echo "🎉 App Registration Complete!"
echo "=============================="
echo ""
echo "📋 Add these values to your .env.local file:"
echo ""
echo "AZURE_TENANT_ID=$tenant_id"
echo "AZURE_CLIENT_ID=$app_id" 
echo "AZURE_CLIENT_SECRET=$client_secret"
echo ""
echo "⚠️  IMPORTANT: Save the client secret now - you won't see it again!"
echo ""
echo "🔍 To verify the setup:"
echo "az login --service-principal --username $app_id --password '$client_secret' --tenant $tenant_id"
echo ""
echo "📚 Next steps:"
echo "1. Add these credentials to your .env.local file"
echo "2. Run 'source scripts/utilities/load-env.sh'"
echo "3. Test with 'scripts/utilities/check-env.sh'"
