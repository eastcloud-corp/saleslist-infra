# General variables
variable "zone" {
  description = "Sakura Cloud zone"
  type        = string
  default     = "is1a"  # 石狩第1ゾーン（最安）
}

variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "github_organization" {
  description = "GitHub organization or username"
  type        = string
}

# Database variables
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "saleslist"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "saleslist_user"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_cpu" {
  description = "Database CPU allocation (millicores)"
  type        = number
  default     = 500
}

variable "db_memory" {
  description = "Database memory allocation (Mi)"
  type        = number
  default     = 1024
}

variable "db_volume_size" {
  description = "Database volume size (Gi)"
  type        = number
  default     = 20
}

# Backend variables
variable "backend_cpu" {
  description = "Backend CPU allocation (millicores)"
  type        = number
  default     = 1000
}

variable "backend_memory" {
  description = "Backend memory allocation (Mi)"
  type        = number
  default     = 2048
}

variable "django_secret_key" {
  description = "Django secret key"
  type        = string
  sensitive   = true
}

variable "allowed_hosts" {
  description = "Django ALLOWED_HOSTS"
  type        = string
  default     = "*"
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins"
  type        = string
  default     = "*"
}

# Frontend variables
variable "frontend_cpu" {
  description = "Frontend CPU allocation (millicores)"
  type        = number
  default     = 500
}

variable "frontend_memory" {
  description = "Frontend memory allocation (Mi)"
  type        = number
  default     = 1024
}