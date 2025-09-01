#!/bin/bash
set -e

# VPS初期化スクリプト
echo "🚀 Sales Navigator VPS初期化開始"

# System update
apt update && apt upgrade -y

# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git
apt install -y git curl nginx

# Clone repositories
cd /opt
git clone https://github.com/eastcloud-corp/saleslist-infra.git
git clone https://github.com/eastcloud-corp/saleslist-backend.git  
git clone https://github.com/eastcloud-corp/saleslist-front.git

# Setup environment variables
cat > /opt/.env << EOF
DB_PASSWORD=${db_password}
DJANGO_SECRET_KEY=${django_secret}
ENVIRONMENT=${environment}
EOF

# Start services
cd /opt/saleslist-infra/docker-compose/prd
docker-compose up -d

# Setup nginx reverse proxy
cat > /etc/nginx/sites-available/salesnav << 'NGINX'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /admin/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

ln -s /etc/nginx/sites-available/salesnav /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl reload nginx

echo "✅ Sales Navigator VPS初期化完了"
echo "🌐 アクセス: http://$(curl -s ifconfig.me)"