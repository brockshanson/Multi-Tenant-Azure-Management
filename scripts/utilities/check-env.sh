#!/bin/bash

# Check environment variables without exposing sensitive values

echo "🔍 Checking environment variable configuration..."

required_vars=(
    "AZURE_TENANT_1_ID"
    "AZURE_CLIENT_1_ID" 
    "AZURE_CLIENT_1_SECRET"
    "AZURE_TENANT_2_ID"
    "AZURE_CLIENT_2_ID"
    "AZURE_CLIENT_2_SECRET"
)

all_set=true

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ $var is not set"
        all_set=false
    else
        # Show that variable is set without exposing the value
        echo "✅ $var is configured"
    fi
done

if [ "$all_set" = true ]; then
    echo ""
    echo "🎉 All required environment variables are properly configured!"
    exit 0
else
    echo ""
    echo "❌ Some environment variables are missing. Run 'source scripts/utilities/load-env.sh' first."
    exit 1
fi
