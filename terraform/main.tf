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
resource "sakuracloud_app_run" "database" {
  name = "${local.app_name}-db-${local.environment}"
  
  container {
    name  = "postgres"
    image = "postgres:15-alpine"
    
    environment_variable {
      name  = "POSTGRES_DB"
      value = var.db_name
    }
    
    environment_variable {
      name  = "POSTGRES_USER"
      value = var.db_user
    }
    
    environment_variable {
      name  = "POSTGRES_PASSWORD"
      value = var.db_password
    }
    
    environment_variable {
      name  = "POSTGRES_INITDB_ARGS"
      value = "--encoding=UTF-8 --locale=ja_JP.UTF-8"
    }
    
    port {
      container_port = 5432
      protocol       = "TCP"
    }
    
    resource {
      cpu    = var.db_cpu
      memory = var.db_memory
    }
    
    volume {
      name       = "postgres-data"
      mount_path = "/var/lib/postgresql/data"
      size       = var.db_volume_size
    }
  }
  
  network_policy {
    ingress_policy = "DENY"
    
    # Allow only backend to access database
    ingress_rule {
      action = "ALLOW"
      source = sakuracloud_app_run.backend.id
      port   = "5432"
    }
  }
  
  tags = values(local.common_tags)
}

# Backend App Run (Django)
resource "sakuracloud_app_run" "backend" {
  name = "${local.app_name}-backend-${local.environment}"
  
  container {
    name  = "django"
    image = "ghcr.io/${var.github_organization}/saleslist-backend:${var.image_tag}"
    
    environment_variable {
      name  = "DEBUG"
      value = "False"
    }
    
    environment_variable {
      name  = "ALLOWED_HOSTS"
      value = var.allowed_hosts
    }
    
    environment_variable {
      name  = "DB_HOST"
      value = sakuracloud_app_run.database.fqdn
    }
    
    environment_variable {
      name  = "DB_NAME"
      value = var.db_name
    }
    
    environment_variable {
      name  = "DB_USER"
      value = var.db_user
    }
    
    environment_variable {
      name  = "DB_PASSWORD"
      value = var.db_password
    }
    
    environment_variable {
      name  = "DB_PORT"
      value = "5432"
    }
    
    environment_variable {
      name  = "SECRET_KEY"
      value = var.django_secret_key
    }
    
    environment_variable {
      name  = "CORS_ALLOWED_ORIGINS"
      value = var.cors_allowed_origins
    }
    
    port {
      container_port = 8000
      protocol       = "TCP"
    }
    
    resource {
      cpu    = var.backend_cpu
      memory = var.backend_memory
    }
    
    probe {
      type               = "HTTP"
      path               = "/health"
      port               = 8000
      initial_delay      = 30
      period             = 10
      timeout            = 5
      failure_threshold  = 3
    }
  }
  
  network_policy {
    ingress_policy = "DENY"
    
    # Allow frontend to access backend
    ingress_rule {
      action = "ALLOW"
      source = sakuracloud_app_run.frontend.id
      port   = "8000"
    }
    
    # Allow external health checks
    ingress_rule {
      action = "ALLOW"
      source = "0.0.0.0/0"
      port   = "8000"
      path   = "/health"
    }
  }
  
  tags = values(local.common_tags)
}

# Frontend App Run (Next.js)
resource "sakuracloud_app_run" "frontend" {
  name = "${local.app_name}-frontend-${local.environment}"
  
  container {
    name  = "nextjs"
    image = "ghcr.io/${var.github_organization}/saleslist-front:${var.image_tag}"
    
    environment_variable {
      name  = "NODE_ENV"
      value = "production"
    }
    
    environment_variable {
      name  = "NEXT_PUBLIC_API_URL"
      value = "https://${sakuracloud_app_run.backend.fqdn}"
    }
    
    environment_variable {
      name  = "PORT"
      value = "3000"
    }
    
    port {
      container_port = 80
      protocol       = "TCP"
    }
    
    resource {
      cpu    = var.frontend_cpu
      memory = var.frontend_memory
    }
    
    probe {
      type               = "HTTP"
      path               = "/health"
      port               = 80
      initial_delay      = 30
      period             = 10
      timeout            = 5
      failure_threshold  = 3
    }
  }
  
  network_policy {
    ingress_policy = "ALLOW"
    
    ingress_rule {
      action = "ALLOW"
      source = "0.0.0.0/0"
      port   = "80"
    }
    
    ingress_rule {
      action = "ALLOW"
      source = "0.0.0.0/0"
      port   = "443"
    }
  }
  
  tags = values(local.common_tags)
}

# Enhanced Global Access Filter (Firewall)
resource "sakuracloud_enhanced_global_access_filter" "main" {
  name        = "${local.app_name}-firewall-${local.environment}"
  description = "Firewall for saleslist application"
  
  filter {
    action      = "allow"
    protocol    = "tcp"
    source_port = "80"
    description = "Allow HTTP"
  }
  
  filter {
    action      = "allow"
    protocol    = "tcp"
    source_port = "443"
    description = "Allow HTTPS"
  }
  
  filter {
    action      = "allow"
    protocol    = "tcp"
    source_port = "8000"
    source_network = sakuracloud_app_run.frontend.fqdn
    description = "Allow frontend to backend"
  }
  
  filter {
    action      = "allow"
    protocol    = "tcp"
    source_port = "5432"
    source_network = sakuracloud_app_run.backend.fqdn
    description = "Allow backend to database"
  }
  
  filter {
    action      = "deny"
    protocol    = "tcp"
    description = "Deny all other TCP"
  }
  
  tags = values(local.common_tags)
}