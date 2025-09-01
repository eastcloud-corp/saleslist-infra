# Output values for other components to use
output "frontend_url" {
  description = "Frontend application URL"
  value       = sakuracloud_apprun_application.frontend.public_url
}

output "backend_url" {
  description = "Backend API URL"
  value       = sakuracloud_apprun_application.backend.public_url
}

output "database_host" {
  description = "Database host"
  value       = sakuracloud_apprun_application.database.public_url
  sensitive   = true
}

output "app_run_frontend_id" {
  description = "Frontend App Run ID"
  value       = sakuracloud_apprun_application.frontend.id
}

output "app_run_backend_id" {
  description = "Backend App Run ID"
  value       = sakuracloud_apprun_application.backend.id
}

output "app_run_database_id" {
  description = "Database App Run ID"
  value       = sakuracloud_apprun_application.database.id
}