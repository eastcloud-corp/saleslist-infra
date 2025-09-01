#!/bin/bash
set -e

# セールスナビゲーター データベースバックアップスクリプト

# 変数定義
SERVICE_NAME="salesnav"
DB_CONTAINER="saleslist_db_prd"
DB_USER="saleslist_prod_user"
DB_NAME="saleslist_production"
BACKUP_DIR="/var/log/${SERVICE_NAME}/backup/database"
DATE_DIR=$(date +%Y%m)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ディレクトリ自動作成（なければ作成）
sudo mkdir -p "${BACKUP_DIR}/${DATE_DIR}"
sudo mkdir -p "${BACKUP_DIR%/database}"/log

# バックアップファイル名
BACKUP_FILE="${BACKUP_DIR}/${DATE_DIR}/backup_${TIMESTAMP}.sql"

echo "🗄️  セールスナビゲーター DBバックアップ開始"
echo "📁 保存先: ${BACKUP_FILE}"

# バックアップ実行
sudo docker exec ${DB_CONTAINER} pg_dump -U ${DB_USER} ${DB_NAME} > ${BACKUP_FILE}

# 結果確認
if [ -f "${BACKUP_FILE}" ]; then
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    echo "✅ バックアップ完了: ${BACKUP_SIZE}"
    echo "📂 ファイル: ${BACKUP_FILE}"
else
    echo "❌ バックアップ失敗"
    exit 1
fi

# 古いバックアップ削除（30日以上）
find ${BACKUP_DIR} -name "backup_*.sql" -mtime +30 -delete 2>/dev/null || true

echo "🎯 バックアップ処理完了"