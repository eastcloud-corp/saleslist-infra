# Staging environment configuration
environment = "staging"
zone        = "is1a"  # 石狩第1ゾーン（最安）

# Database configuration
db_name     = "saleslist_staging"
db_user     = "saleslist_staging_user"
db_cpu      = 500
db_memory   = 1024
db_volume_size = 10

# Backend configuration
backend_cpu    = 500
backend_memory = 1024
allowed_hosts  = "saleslist-frontend-staging.sakura.app,localhost"
cors_allowed_origins = "https://saleslist-frontend-staging.sakura.app,http://localhost:3000"

# Frontend configuration
frontend_cpu    = 250
frontend_memory = 512

# Image tag
image_tag = "staging"

# GitHub organization
github_organization = "eastcloud-corp"

# Custom domain
custom_domain = "sales-navigator-staging.sakura.app"