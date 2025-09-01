#!/bin/bash
set -e

# SSL証明書自動更新とログローテーション cron設定

echo "⚙️  cron設定開始"

# 現在のcronを取得
sudo crontab -l > /tmp/current_cron 2>/dev/null || echo "" > /tmp/current_cron

# SSL証明書自動更新（毎月1日3時）
if ! grep -q "certbot renew" /tmp/current_cron; then
    echo "0 3 1 * * /usr/bin/certbot renew --quiet --nginx" >> /tmp/current_cron
    echo "✅ SSL自動更新 cron追加"
fi

# DBバックアップ（毎日2時）
if ! grep -q "backup-db.sh" /tmp/current_cron; then
    echo "0 2 * * * /opt/salesnav/saleslist-infra/scripts/backup-db.sh" >> /tmp/current_cron
    echo "✅ DBバックアップ cron追加"
fi

# ログローテーション（毎日4時）
if ! grep -q "logrotate" /tmp/current_cron; then
    echo "0 4 * * * /usr/sbin/logrotate /etc/logrotate.conf" >> /tmp/current_cron
    echo "✅ ログローテーション cron追加"
fi

# cron設定適用
sudo crontab /tmp/current_cron
sudo rm /tmp/current_cron

echo "🎯 cron設定完了"
echo "📋 設定内容:"
echo "   2:00 - DBバックアップ"
echo "   3:00 - SSL証明書更新（毎月1日）"
echo "   4:00 - ログローテーション"

# 設定確認
echo ""
echo "📋 現在のcron設定:"
sudo crontab -l