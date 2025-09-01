#!/bin/bash

# Deployment script for Sakura Cloud App Run
# Usage: ./deploy.sh [staging|production]

set -e

ENVIRONMENT=${1:-staging}
SCRIPT_DIR=$(cd $(dirname $0) && pwd)
PROJECT_ROOT=$(cd $SCRIPT_DIR/../.. && pwd)
INFRA_DIR=$PROJECT_ROOT/saleslist-infra

echo "🚀 Starting deployment for environment: $ENVIRONMENT"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
    echo "❌ Error: Environment must be 'staging' or 'production'"
    exit 1
fi

# Check if required tools are installed
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed. Aborting." >&2; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is required but not installed. Aborting." >&2; exit 1; }

echo "📦 Building Docker images..."

# Build backend image
echo "Building backend image..."
cd $PROJECT_ROOT
docker build -f $INFRA_DIR/docker/backend/Dockerfile.prod -t saleslist-backend:$ENVIRONMENT .

# Build frontend image
echo "Building frontend image..."
docker build -f $INFRA_DIR/docker/frontend/Dockerfile.prod -t saleslist-frontend:$ENVIRONMENT .

# Get container registry URL from Terraform
cd $INFRA_DIR/terraform
REGISTRY_URL=$(terraform output -raw container_registry_url 2>/dev/null || echo "")

if [ -n "$REGISTRY_URL" ]; then
    echo "📤 Pushing images to registry: $REGISTRY_URL"
    
    # Tag and push backend image
    docker tag saleslist-backend:$ENVIRONMENT $REGISTRY_URL/saleslist-backend:$ENVIRONMENT
    docker push $REGISTRY_URL/saleslist-backend:$ENVIRONMENT
    
    # Tag and push frontend image
    docker tag saleslist-frontend:$ENVIRONMENT $REGISTRY_URL/saleslist-frontend:$ENVIRONMENT
    docker push $REGISTRY_URL/saleslist-frontend:$ENVIRONMENT
else
    echo "⚠️  Registry URL not found. Skipping image push."
fi

echo "🏗️  Applying Terraform configuration..."

# Apply Terraform
terraform init
terraform plan -var-file="environments/$ENVIRONMENT.tfvars"
terraform apply -var-file="environments/$ENVIRONMENT.tfvars" -auto-approve

echo "🎉 Deployment completed successfully!"

# Display URLs
FRONTEND_URL=$(terraform output -raw frontend_url 2>/dev/null || echo "")
BACKEND_URL=$(terraform output -raw backend_url 2>/dev/null || echo "")

if [ -n "$FRONTEND_URL" ]; then
    echo "🌐 Frontend URL: $FRONTEND_URL"
fi

if [ -n "$BACKEND_URL" ]; then
    echo "🔗 Backend URL: $BACKEND_URL"
fi

echo "✅ Deployment script completed."