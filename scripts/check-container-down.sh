#!/bin/bash

# Script to check if containers are down and send Slack alert
# Usage: ./check-container-down.sh

set -e

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
CONFIG_FILE="/opt/salesnav/.slack-config"

# Load Slack webhook URL if available
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

containers=(
    "saleslist_frontend_prd"
    "saleslist_backend_prd"
    "saleslist_worker_prd"
    "saleslist_beat_prd"
    "saleslist_db_prd"
    "saleslist_redis_prd"
)

down_containers=()

for container in "${containers[@]}"; do
    if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        down_containers+=("$container")
    fi
done

if [ ${#down_containers[@]} -gt 0 ]; then
    message="🚨 CRITICAL: The following containers are DOWN: ${down_containers[*]}"
    echo "$message"
    
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        "$SCRIPT_DIR/slack-notify.sh" "$message" "--level critical"
    else
        echo "⚠️  SLACK_WEBHOOK_URL is not set. Skipping Slack notification."
    fi
    
    exit 1
else
    echo "✅ All containers are running"
    exit 0
fi

