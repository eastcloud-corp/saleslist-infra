# Staging environment configuration
environment = "staging"
zone        = "is1a"  # 石狩第1ゾーン（最安）

# Database configuration
db_name     = "saleslist_staging"
db_user     = "saleslist_staging_user"
db_cpu      = "0.5"
db_memory   = "1Gi"
db_volume_size = 10

# Backend configuration
backend_cpu    = "0.5"
backend_memory = "1Gi"
allowed_hosts  = "saleslist-frontend-staging.sakura.app,localhost"
cors_allowed_origins = "https://saleslist-frontend-staging.sakura.app,http://localhost:3000"

# Frontend configuration
frontend_cpu    = "0.3"
frontend_memory = "512Mi"

# Image tag
image_tag = "staging"

# GitHub organization
github_organization = "eastcloud-corp"

# Custom domain
custom_domain = "sales-navigator-staging.sakura.app"