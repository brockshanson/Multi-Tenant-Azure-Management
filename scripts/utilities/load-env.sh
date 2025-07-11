#!/bin/bash

# Load environment variables for multi-tenant Azure management

ENV_FILE=".env.local"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Environment file $ENV_FILE not found"
    echo "📝 Copy .env.template to .env.local and configure your secrets"
    exit 1
fi

# Load environment variables
set -a
source "$ENV_FILE"
set +a

echo "✅ Environment variables loaded from $ENV_FILE"

# Verify required variables are set (without exposing values)
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
    echo "❌ Missing required environment variables:"
    printf '%s\n' "${missing_vars[@]}"
    exit 1
fi

echo "✅ All required environment variables are set"
