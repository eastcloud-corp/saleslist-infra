#!/bin/bash
set -e

# セールスナビゲーター ログディレクトリ構造作成スクリプト

SERVICE_NAME="salesnav"
LOG_BASE="/var/log/${SERVICE_NAME}"
CURRENT_MONTH=$(date +%Y%m)

echo "📁 ログディレクトリ構造作成開始"

# 基本ディレクトリ作成
sudo mkdir -p "${LOG_BASE}/backend"
sudo mkdir -p "${LOG_BASE}/frontend"
sudo mkdir -p "${LOG_BASE}/backup/database/${CURRENT_MONTH}"
sudo mkdir -p "${LOG_BASE}/backup/log/${CURRENT_MONTH}"

# 権限設定（各サービスのユーザーに合わせる）
sudo chmod 755 "${LOG_BASE}"
sudo chmod 755 "${LOG_BASE}/backend"
sudo chmod 755 "${LOG_BASE}/frontend" 
sudo chmod 755 "${LOG_BASE}/backup"

# Djangoコンテナユーザー(django:1001)用
sudo chown -R 1001:1001 "${LOG_BASE}/backend"

# Nginx/root用 
sudo chown -R root:root "${LOG_BASE}/frontend"
sudo chown -R root:root "${LOG_BASE}/backup"

echo "✅ ログディレクトリ構造作成完了"
echo "📂 構造:"
echo "   ${LOG_BASE}/"
echo "   ├── backend/"
echo "   ├── frontend/"
echo "   └── backup/"
echo "       ├── database/${CURRENT_MONTH}/"
echo "       └── log/${CURRENT_MONTH}/"

# 初期ログファイル作成
sudo touch "${LOG_BASE}/backend/django.log"
sudo touch "${LOG_BASE}/backend/error.log"
sudo touch "${LOG_BASE}/frontend/access.log"
sudo touch "${LOG_BASE}/frontend/error.log"

# ログローテーション設定（シェルスクリプト呼び出し方式）
sudo tee /etc/logrotate.d/salesnav << 'EOF'
/var/log/salesnav/backend/*.log /var/log/salesnav/frontend/*.log {
    daily
    missingok
    notifempty
    sharedscripts
    postrotate
        /opt/salesnav/saleslist-infra/scripts/log-rotate.sh
    endscript
}
EOF

# スクリプト実行権限付与
sudo chmod +x /opt/salesnav/saleslist-infra/scripts/log-rotate.sh

echo "✅ ログローテーション設定完了（シェルスクリプト方式・90日保持）"