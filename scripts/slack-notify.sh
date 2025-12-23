#!/bin/bash

# Slack notification script for monitoring alerts
# Usage: ./slack-notify.sh "message" [--level info|warning|error|critical]

set -e

MESSAGE="${1:-}"
LEVEL="${2:---level info}"

# Load Slack webhook URL from environment or config file
CONFIG_FILE="/opt/salesnav/.slack-config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "⚠️  SLACK_WEBHOOK_URL is not set. Skipping Slack notification."
    exit 0
fi

if [ -z "$MESSAGE" ]; then
    echo "Usage: $0 'message' [--level info|warning|error|critical]"
    exit 1
fi

# Determine color and emoji based on level
case "$LEVEL" in
    --level critical|critical)
        COLOR="danger"
        EMOJI="🚨"
        TITLE="Critical Alert"
        ;;
    --level error|error)
        COLOR="danger"
        EMOJI="❌"
        TITLE="Error Alert"
        ;;
    --level warning|warning)
        COLOR="warning"
        EMOJI="⚠️"
        TITLE="Warning Alert"
        ;;
    *)
        COLOR="good"
        EMOJI="ℹ️"
        TITLE="Info"
        ;;
esac

# Get server info
SERVER_NAME=$(hostname)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Create Slack payload
PAYLOAD=$(cat <<EOF
{
  "attachments": [
    {
      "color": "${COLOR}",
      "title": "${EMOJI} ${TITLE} - Sales Navigator",
      "fields": [
        {
          "title": "Server",
          "value": "${SERVER_NAME}",
          "short": true
        },
        {
          "title": "Time",
          "value": "${TIMESTAMP}",
          "short": true
        },
        {
          "title": "Message",
          "value": "${MESSAGE}",
          "short": false
        }
      ],
      "footer": "Sales Navigator Monitoring",
      "ts": $(date +%s)
    }
  ]
}
EOF
)

# Send to Slack
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -H 'Content-type: application/json' \
    --data "$PAYLOAD" \
    "$SLACK_WEBHOOK_URL" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Slack notification sent successfully"
else
    echo "❌ Failed to send Slack notification (HTTP $HTTP_CODE)"
    echo "Response: $RESPONSE"
    exit 1
fi

