# Secret Management Guide

This guide covers secure handling of Azure credentials, client secrets, and sensitive configuration for the multi-tenant management system.

## Overview

The secret management strategy uses multiple layers:

1. **Environment Variables** - Runtime secrets
2. **Azure Key Vault** - Production secret storage
3. **Local Secret Files** - Development (git-ignored)
4. **MCP Server Configuration** - Secure credential passing

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

### Environment File Template

Create `.env.local` (git-ignored) for local development:

```bash
# Copy to .env.local and fill in actual values
AZURE_TENANT_1_ID=ef63f3e9-134f-428f-b601-1bfe781034f8
AZURE_CLIENT_1_ID=16554e45-c734-480d-bb04-9f9fe7a3ab5e
AZURE_CLIENT_1_SECRET=your_actual_secret_here

AZURE_TENANT_2_ID=049d5c8d-0cb4-4880-bc97-8a770b44be56
AZURE_CLIENT_2_ID=15315bba-3aa4-46c6-be01-955198f119e0
AZURE_CLIENT_2_SECRET=your_actual_secret_here
```

## MCP Server Secret Configuration

### Lokka MCP Configuration with Environment Variables

```json
{
  "mcpServers": {
    "lokka-dasein": {
      "command": "lokka",
      "args": [
        "--tenant-id", "${AZURE_TENANT_1_ID}",
        "--client-id", "${AZURE_CLIENT_1_ID}",
        "--client-secret", "${AZURE_CLIENT_1_SECRET}"
      ]
    },
    "lokka-spectral": {
      "command": "lokka", 
      "args": [
        "--tenant-id", "${AZURE_TENANT_2_ID}",
        "--client-id", "${AZURE_CLIENT_2_ID}",
        "--client-secret", "${AZURE_CLIENT_2_SECRET}"
      ]
    }
  }
}
```

### Secure Configuration Loading

Use the provided script to load environment variables:

```bash
# Load secrets from .env.local
source config/secrets/load-env.sh

# Verify configuration (without exposing secrets)
./scripts/utilities/verify-config.sh
```

## Azure Key Vault Integration

### Production Secret Storage

```bash
# Store secrets in Azure Key Vault
az keyvault secret set \
  --vault-name "multi-tenant-secrets" \
  --name "azure-client-1-secret" \
  --value "$AZURE_CLIENT_1_SECRET"

az keyvault secret set \
  --vault-name "multi-tenant-secrets" \
  --name "azure-client-2-secret" \
  --value "$AZURE_CLIENT_2_SECRET"
```

### Retrieve from Key Vault

```bash
# Retrieve secrets for production use
AZURE_CLIENT_1_SECRET=$(az keyvault secret show \
  --vault-name "multi-tenant-secrets" \
  --name "azure-client-1-secret" \
  --query "value" -o tsv)
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
