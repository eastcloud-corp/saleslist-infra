#!/bin/bash

# Health check script for deployment validation
# Usage: ./health-check.sh [staging|production]

set -e

ENVIRONMENT=${1:-staging}
SCRIPT_DIR=$(cd $(dirname $0) && pwd)
INFRA_DIR=$(cd $SCRIPT_DIR/.. && pwd)

echo "🏥 Running health checks for environment: $ENVIRONMENT"

# Get URLs from Terraform outputs
cd $INFRA_DIR/terraform
FRONTEND_URL=$(terraform output -raw frontend_url 2>/dev/null || echo "")
BACKEND_URL=$(terraform output -raw backend_url 2>/dev/null || echo "")

if [ -z "$FRONTEND_URL" ] || [ -z "$BACKEND_URL" ]; then
    echo "❌ Error: Could not get URLs from Terraform outputs"
    exit 1
fi

echo "🔍 Checking frontend health: $FRONTEND_URL"
response=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL/health" || echo "000")
if [ "$response" = "200" ]; then
    echo "✅ Frontend is healthy"
else
    echo "❌ Frontend health check failed (HTTP $response)"
    exit 1
fi

echo "🔍 Checking backend health: $BACKEND_URL"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/health" || echo "000")
if [ "$response" = "200" ]; then
    echo "✅ Backend is healthy"
else
    echo "❌ Backend health check failed (HTTP $response)"
    exit 1
fi

echo "🔍 Checking database connectivity..."
response=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/api/health/db" || echo "000")
if [ "$response" = "200" ]; then
    echo "✅ Database is accessible"
else
    echo "❌ Database connectivity check failed (HTTP $response)"
    exit 1
fi

echo "🎉 All health checks passed successfully!"