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

# Load master data using management command
echo "Loading master data using management command..."
python manage.py load_master_data

if [[ "${ENABLE_SAMPLE_DATA:-False}" == "True" ]]; then
    echo "Seeding sample data (ENABLE_SAMPLE_DATA=True)..."
    python seed_data.py || echo "⚠️ Sample data seeding encountered an issue (continuing)"
fi

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create cache table if using database cache
echo "Creating cache table..."
python manage.py createcachetable

echo "Starting application..."
exec "$@"
