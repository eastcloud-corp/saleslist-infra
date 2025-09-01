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

# VPS Server
resource "sakuracloud_server" "main" {
  name  = "${local.app_name}-server-${local.environment}"
  disks = [sakuracloud_disk.main.id]
  
  core   = 2
  memory = 4
  
  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.main.id
  }
  
  user_data = templatefile("${path.module}/../scripts/vps-init.sh", {
    db_password     = var.db_password
    django_secret   = var.django_secret_key
    environment     = var.environment
  })
}

# Disk for VPS
resource "sakuracloud_disk" "main" {
  name = "${local.app_name}-disk-${local.environment}"
  size = 40
}

# Packet Filter (Firewall)
resource "sakuracloud_packet_filter" "main" {
  name        = "${local.app_name}-filter-${local.environment}"
  description = "Firewall for sales navigator VPS"
  
  expression {
    protocol    = "tcp"
    source_port = "22"
    allow       = true
    description = "SSH"
  }
  
  expression {
    protocol    = "tcp"
    source_port = "80"
    allow       = true
    description = "HTTP"
  }
  
  expression {
    protocol    = "tcp"
    source_port = "443"
    allow       = true
    description = "HTTPS"
  }
  
  expression {
    protocol = "icmp"
    allow    = true
    description = "ICMP"
  }
  
  expression {
    protocol = "fragment"
    allow    = true
    description = "Fragment"
  }
  
  expression {
    protocol = "tcp"
    allow    = false
    description = "Deny all other TCP"
  }
  
  expression {
    protocol = "udp"
    allow    = false
    description = "Deny all other UDP"
  }
}