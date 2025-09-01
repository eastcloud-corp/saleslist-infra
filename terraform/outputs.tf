# Output values for VPS deployment
output "server_ip" {
  description = "VPS Server IP Address"
  value       = sakuracloud_server.main.ip_address
}

output "server_url" {
  description = "Application URL"
  value       = "http://${sakuracloud_server.main.ip_address}"
}

output "server_ssh" {
  description = "SSH Access"
  value       = "ssh root@${sakuracloud_server.main.ip_address}"
}

output "server_id" {
  description = "VPS Server ID"
  value       = sakuracloud_server.main.id
}