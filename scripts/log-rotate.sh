#!/bin/bash
set -e

# セールスナビゲーター ログローテーション・アーカイブスクリプト

SERVICE_NAME="salesnav"
LOG_BASE="/var/log/${SERVICE_NAME}"
CURRENT_MONTH=$(date +%Y%m)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🔄 ログローテーション開始: ${TIMESTAMP}"

# アーカイブディレクトリ自動作成（なければ作成）
sudo mkdir -p "${LOG_BASE}/backup/log/${CURRENT_MONTH}"
sudo mkdir -p "${LOG_BASE}/backend"
sudo mkdir -p "${LOG_BASE}/frontend"

# バックエンドログアーカイブ
if [ -f "${LOG_BASE}/backend/django.log" ] && [ -s "${LOG_BASE}/backend/django.log" ]; then
    sudo gzip -c "${LOG_BASE}/backend/django.log" > "${LOG_BASE}/backup/log/${CURRENT_MONTH}/django_${TIMESTAMP}.log.gz"
    sudo truncate -s 0 "${LOG_BASE}/backend/django.log"
    echo "✅ Django log archived"
fi

if [ -f "${LOG_BASE}/backend/error.log" ] && [ -s "${LOG_BASE}/backend/error.log" ]; then
    sudo gzip -c "${LOG_BASE}/backend/error.log" > "${LOG_BASE}/backup/log/${CURRENT_MONTH}/backend_error_${TIMESTAMP}.log.gz"
    sudo truncate -s 0 "${LOG_BASE}/backend/error.log"
    echo "✅ Backend error log archived"
fi

# フロントエンドログアーカイブ
if [ -f "${LOG_BASE}/frontend/access.log" ] && [ -s "${LOG_BASE}/frontend/access.log" ]; then
    sudo gzip -c "${LOG_BASE}/frontend/access.log" > "${LOG_BASE}/backup/log/${CURRENT_MONTH}/frontend_access_${TIMESTAMP}.log.gz"
    sudo truncate -s 0 "${LOG_BASE}/frontend/access.log"
    echo "✅ Frontend access log archived"
fi

if [ -f "${LOG_BASE}/frontend/error.log" ] && [ -s "${LOG_BASE}/frontend/error.log" ]; then
    sudo gzip -c "${LOG_BASE}/frontend/error.log" > "${LOG_BASE}/backup/log/${CURRENT_MONTH}/frontend_error_${TIMESTAMP}.log.gz"
    sudo truncate -s 0 "${LOG_BASE}/frontend/error.log"
    echo "✅ Frontend error log archived"
fi

# 古いアーカイブ削除（90日以上）
find "${LOG_BASE}/backup/log" -name "*.log.gz" -mtime +90 -delete 2>/dev/null || true

echo "🎯 ログローテーション完了"