# Output values for other components to use
output "frontend_url" {
  description = "Frontend application URL"
  value       = "https://${sakuracloud_app_run.frontend.fqdn}"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "https://${sakuracloud_app_run.backend.fqdn}"
}

output "database_host" {
  description = "Database host"
  value       = sakuracloud_app_run.database.fqdn
  sensitive   = true
}

output "container_registry_url" {
  description = "Container registry URL"
  value       = sakuracloud_container_registry.main.fqdn
}

output "app_run_frontend_id" {
  description = "Frontend App Run ID"
  value       = sakuracloud_app_run.frontend.id
}

output "app_run_backend_id" {
  description = "Backend App Run ID"
  value       = sakuracloud_app_run.backend.id
}

output "app_run_database_id" {
  description = "Database App Run ID"
  value       = sakuracloud_app_run.database.id
}