#!/bin/bash

# Container monitoring script for production
# Monitors CPU usage, memory usage, and process counts
# Usage: ./monitor-containers.sh [--alert]

set -e

ALERT_MODE=${1:-""}
SCRIPT_DIR=$(cd $(dirname $0) && pwd)
LOG_DIR="/var/log/salesnav"
MONITOR_LOG="$LOG_DIR/monitor.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Thresholds for alerts
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
PROCESS_COUNT_THRESHOLD=50

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MONITOR_LOG"
}

check_container() {
    local container_name=$1
    local stats=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemPerc}},{{.MemUsage}}" "$container_name" 2>/dev/null || echo "")
    
    if [ -z "$stats" ]; then
        log_message "⚠️  Container $container_name is not running"
        return 1
    fi
    
    IFS=',' read -r cpu_perc mem_perc mem_usage <<< "$stats"
    cpu_perc=${cpu_perc%\%}
    mem_perc=${mem_perc%\%}
    
    # Count processes in container
    local process_count=$(docker top "$container_name" 2>/dev/null | wc -l || echo "0")
    process_count=$((process_count - 1)) # Subtract header line
    
    log_message "📊 $container_name: CPU=${cpu_perc}% Memory=${mem_perc}% Processes=$process_count"
    
    # Check for hanging curl processes (health check issue)
    local curl_count=$(docker top "$container_name" 2>/dev/null | grep -c "curl" || echo "0")
    if [ "$curl_count" -gt 10 ]; then
        log_message "🚨 WARNING: $container_name has $curl_count curl processes (possible health check issue)"
        if [ "$ALERT_MODE" = "--alert" ]; then
            # Could send alert notification here
            echo "ALERT: $container_name has excessive curl processes"
        fi
    fi
    
    # Alert if thresholds exceeded
    if [ "$ALERT_MODE" = "--alert" ]; then
        if (( $(echo "$cpu_perc > $CPU_THRESHOLD" | bc -l) )); then
            log_message "🚨 ALERT: $container_name CPU usage is ${cpu_perc}% (threshold: ${CPU_THRESHOLD}%)"
        fi
        
        if (( $(echo "$mem_perc > $MEMORY_THRESHOLD" | bc -l) )); then
            log_message "🚨 ALERT: $container_name Memory usage is ${mem_perc}% (threshold: ${MEMORY_THRESHOLD}%)"
        fi
        
        if [ "$process_count" -gt "$PROCESS_COUNT_THRESHOLD" ]; then
            log_message "🚨 ALERT: $container_name has $process_count processes (threshold: ${PROCESS_COUNT_THRESHOLD})"
        fi
    fi
    
    return 0
}

# Main monitoring
log_message "🔍 Starting container monitoring..."

containers=(
    "saleslist_frontend_prd"
    "saleslist_backend_prd"
    "saleslist_worker_prd"
    "saleslist_beat_prd"
    "saleslist_db_prd"
    "saleslist_redis_prd"
)

all_healthy=true
for container in "${containers[@]}"; do
    if ! check_container "$container"; then
        all_healthy=false
    fi
done

# Check overall system health
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
log_message "💾 Disk usage: ${disk_usage}%"

if [ "$all_healthy" = true ]; then
    log_message "✅ All containers are running"
else
    log_message "❌ Some containers have issues"
    exit 1
fi

