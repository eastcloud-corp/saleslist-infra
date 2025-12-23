#!/bin/bash

# Script to check and analyze frontend container errors
# Usage: ./check-frontend-errors.sh

set -e

CONTAINER_NAME="saleslist_frontend_prd"
LOG_LINES=100

echo "🔍 Checking frontend container errors..."

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Container ${CONTAINER_NAME} is not running"
    exit 1
fi

echo "📊 Analyzing recent logs (last ${LOG_LINES} lines)..."
echo ""

# Count error types
echo "=== Error Summary ==="
docker logs --tail ${LOG_LINES} ${CONTAINER_NAME} 2>&1 | grep -i "error" | \
    awk '{
        if (/Server Action/) print "Server Action Error"
        else if (/Unexpected end of form/) print "Form Processing Error"
        else if (/Malformed part header/) print "Multipart Error"
        else if (/Boundary not found/) print "Boundary Error"
        else print "Other Error"
    }' | sort | uniq -c | sort -rn

echo ""
echo "=== Recent Errors (last 20) ==="
docker logs --tail ${LOG_LINES} ${CONTAINER_NAME} 2>&1 | grep -i "error" | tail -20

echo ""
echo "=== Container Health ==="
docker inspect ${CONTAINER_NAME} --format 'Health Status: {{.State.Health.Status}}' 2>/dev/null || echo "No health check configured"

echo ""
echo "=== Process Count ==="
process_count=$(docker top ${CONTAINER_NAME} 2>/dev/null | wc -l)
echo "Total processes: $((process_count - 1))"  # Subtract header

curl_count=$(docker top ${CONTAINER_NAME} 2>/dev/null | grep -c "curl" || echo "0")
echo "Curl processes: ${curl_count}"

if [ "$curl_count" -gt 10 ]; then
    echo "⚠️  WARNING: Excessive curl processes detected (possible health check issue)"
fi

echo ""
echo "✅ Error check complete"

