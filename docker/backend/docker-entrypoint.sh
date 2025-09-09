#!/bin/bash
set -e

# Wait for database to be ready
echo "Waiting for database..."
while ! python manage.py check --database default > /dev/null 2>&1; do
    echo "Database is unavailable - sleeping"
    sleep 1
done
echo "Database is up - continuing..."

# Run database migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Create superuser if it doesn't exist
echo "Creating superuser if needed..."
python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='salesnav_admin@budget-sales.com').exists():
    User.objects.create_superuser(
        username='salesnav_admin',
        email='salesnav_admin@budget-sales.com', 
        name='システム管理者',
        password='salesnav20250901'
    )
    print('Superuser created: salesnav_admin')
else:
    print('Superuser already exists: salesnav_admin')
"

# Load master data
echo "Loading master data..."
python manage.py shell -c "
from masters.models import *

# ProjectProgressStatus
if not ProjectProgressStatus.objects.exists():
    statuses = [
        '未着手', '着手中', '進行中', '一時停止', '完了', '中止', 
        '保留', '要確認', '承認待ち', '修正中', 'テスト中', 
        '運用開始', 'クローズ', '要見直し'
    ]
    for status in statuses:
        ProjectProgressStatus.objects.create(name=status)
    print(f'Created {len(statuses)} ProjectProgressStatus records')

# MediaType
if not MediaType.objects.exists():
    media_types = ['Facebook', 'Instagram', 'Twitter', 'LinkedIn', 'TikTok', 'YouTube']
    for media in media_types:
        MediaType.objects.create(name=media)
    print(f'Created {len(media_types)} MediaType records')

# ServiceType
if not ServiceType.objects.exists():
    service_types = [
        'コンサルティング', 'システム開発', 'マーケティング支援', 'セールス代行',
        'データ分析', '業務改善', 'DX推進', 'クラウド移行', 'セキュリティ対策',
        'インフラ構築', 'アプリ開発', 'ホームページ制作', 'ECサイト構築',
        '社内システム開発', 'AI・機械学習', 'IoT導入', 'RPA導入', 'CRM導入',
        'ERP導入', 'BI導入', 'Web制作', 'SEO対策', 'SNS運用', 'ブランディング',
        '採用支援', '人材育成', '組織改革', '財務コンサル', '法務支援', 
        'IP戦略', 'M&A支援', '海外展開', 'パートナーシップ', '投資家紹介',
        'PR・広報', 'イベント企画', '営業代行', 'テレアポ代行', 'リード獲得',
        'カスタマーサクセス', 'サポート業務', 'BPO', '翻訳・通訳', '法人営業',
        '個人営業', 'B2B営業', 'B2C営業', 'インサイドセールス', 'フィールドセールス',
        'アカウント営業', 'ソリューション営業', 'テクニカルセールス', 'その他'
    ]
    for service in service_types:
        ServiceType.objects.create(name=service)
    print(f'Created {len(service_types)} ServiceType records')

# RegularMeetingStatus
if not RegularMeetingStatus.objects.exists():
    meeting_statuses = ['未設定', '週次', '隔週', '月次', '不定期', '停止中']
    for status in meeting_statuses:
        RegularMeetingStatus.objects.create(name=status)
    print(f'Created {len(meeting_statuses)} RegularMeetingStatus records')

# ListAvailability  
if not ListAvailability.objects.exists():
    availabilities = ['利用可能', '利用不可', '要確認']
    for availability in availabilities:
        ListAvailability.objects.create(name=availability)
    print(f'Created {len(availabilities)} ListAvailability records')

# ListImportSource
if not ListImportSource.objects.exists():
    import_sources = ['CSV手動', 'API連携', 'スクレイピング', '外部DB', '手動入力', 'その他']
    for source in import_sources:
        ListImportSource.objects.create(name=source)
    print(f'Created {len(import_sources)} ListImportSource records')

print('Master data initialization completed!')
"

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create cache table if using database cache
echo "Creating cache table..."
python manage.py createcachetable

echo "Starting application..."
exec "$@"