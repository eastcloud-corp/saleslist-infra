# Production environment configuration
environment = "production"
zone        = "is1a"  # 石狩第1ゾーン（最安）

# Database configuration
db_name     = "saleslist_production"
db_user     = "saleslist_prod_user"
db_cpu      = "0.5"
db_memory   = "1Gi"
db_volume_size = 20

# Backend configuration
backend_cpu    = "0.5"
backend_memory = "1Gi"
allowed_hosts  = "saleslist-frontend-production.sakura.app,budget-sales.com"
cors_allowed_origins = "https://saleslist-frontend-production.sakura.app,https://budget-sales.com"

# Frontend configuration
frontend_cpu    = "0.3"
frontend_memory = "512Mi"

# Image tag
image_tag = "latest"

# GitHub organization
github_organization = "eastcloud-corp"

# Custom domain
custom_domain = "sales-navigator.sakura.app"