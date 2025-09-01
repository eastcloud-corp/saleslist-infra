terraform {
  required_version = ">= 1.0"
  required_providers {
    sakuracloud = {
      source  = "sacloud/sakuracloud"
      version = "~> 2.25"
    }
  }
}

# Configure the Sakura Cloud Provider
provider "sakuracloud" {
  zone = var.zone
}

# Local variables
locals {
  app_name = "salesnav"
  environment = var.environment
  
  common_tags = {
    Environment = var.environment
    Project     = "sales-navigator"
    ManagedBy   = "terraform"
  }
}

# Note: Using GitHub Container Registry (ghcr.io) instead of Sakura Container Registry
# This saves approximately 1,000 yen/month

# Database App Run (PostgreSQL)
resource "sakuracloud_apprun_application" "database" {
  name            = "${local.app_name}-db-${local.environment}"
  timeout_seconds = 60
  port            = 5432
  min_scale       = 1
  max_scale       = 1

  components {
    name       = "postgres"
    max_cpu    = "${var.db_cpu}m"
    max_memory = "${var.db_memory}Mi"

    deploy_source {
      container_registry {
        image    = "postgres:15-alpine"
        username = ""
        password = ""
      }
    }

    env {
      key   = "POSTGRES_DB"
      value = var.db_name
    }
    
    env {
      key   = "POSTGRES_USER"
      value = var.db_user
    }
    
    env {
      key   = "POSTGRES_PASSWORD"
      value = var.db_password
    }
  }
}

# Backend App Run (Django)
resource "sakuracloud_apprun_application" "backend" {
  name            = "${local.app_name}-backend-${local.environment}"
  timeout_seconds = 60
  port            = 8000
  min_scale       = 1
  max_scale       = 3

  components {
    name       = "django"
    max_cpu    = "${var.backend_cpu}m"
    max_memory = "${var.backend_memory}Mi"

    deploy_source {
      container_registry {
        image    = "ghcr.io/${var.github_organization}/saleslist-backend:${var.image_tag}"
        username = var.github_organization
        password = ""
      }
    }

    env {
      key   = "DEBUG"
      value = "False"
    }
    
    env {
      key   = "ALLOWED_HOSTS"
      value = var.allowed_hosts
    }
    
    env {
      key   = "DB_HOST"
      value = sakuracloud_apprun_application.database.public_url
    }
    
    env {
      key   = "DB_NAME"
      value = var.db_name
    }
    
    env {
      key   = "DB_USER"
      value = var.db_user
    }
    
    env {
      key   = "DB_PASSWORD"
      value = var.db_password
    }
    
    env {
      key   = "SECRET_KEY"
      value = var.django_secret_key
    }
    
    env {
      key   = "CORS_ALLOWED_ORIGINS"
      value = var.cors_allowed_origins
    }
  }
}

# Frontend App Run (Next.js)
resource "sakuracloud_apprun_application" "frontend" {
  name = "${local.app_name}-frontend-${local.environment}"
  
  timeout_seconds = 60
  port            = 3000
  min_scale       = 1
  max_scale       = 3

  components {
    name       = "nextjs"
    max_cpu    = "${var.frontend_cpu}m"
    max_memory = "${var.frontend_memory}Mi"

    deploy_source {
      container_registry {
        image    = "ghcr.io/${var.github_organization}/saleslist-front:${var.image_tag}"
        username = var.github_organization
        password = ""
      }
    }

    env {
      key   = "NODE_ENV"
      value = "production"
    }
    
    env {
      key   = "NEXT_PUBLIC_API_URL"
      value = sakuracloud_apprun_application.backend.public_url
    }
    
    env {
      key   = "PORT"
      value = "3000"
    }
  }
}

# Note: App Run applications have built-in firewall
# No additional packet filter needed for basic setup