#!/usr/bin/env bash
# health-check.sh — Check all Docker Compose services and alert via Telegram
# Usage: ./scripts/health-check.sh
# Cron:  */5 * * * * /opt/infra/scripts/health-check.sh

set -euo pipefail

COMPOSE_FILE="/opt/infra/prod/docker-compose.yml"
ENV_FILE="/opt/infra/prod/.env"

# Load env vars (TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID)
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +a
fi

if [[ -z "${TELEGRAM_BOT_TOKEN:-}" || -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  echo "ERROR: TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID must be set in $ENV_FILE"
  exit 1
fi

send_telegram() {
  local message="$1"
  curl -s -X POST \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d text="${message}" \
    -d parse_mode="HTML" \
    > /dev/null 2>&1
}

HOSTNAME=$(hostname)
FAILED_SERVICES=()

# Get all services and their status
while IFS= read -r line; do
  service=$(echo "$line" | awk '{print $1}')
  status=$(echo "$line" | awk '{print $2}')
  health=$(echo "$line" | awk '{print $3}')

  # Skip header or empty lines
  [[ -z "$service" || "$service" == "NAME" ]] && continue

  # Check for non-running states
  if [[ "$status" != "running" ]]; then
    FAILED_SERVICES+=("$service ($status)")
  elif [[ "$health" == "(unhealthy)" ]]; then
    FAILED_SERVICES+=("$service (unhealthy)")
  fi
done < <(docker compose -f "$COMPOSE_FILE" ps --format "table {{.Name}}\t{{.State}}\t{{.Health}}" 2>/dev/null)

# Check disk usage
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [[ "$DISK_USAGE" -gt 85 ]]; then
  FAILED_SERVICES+=("DISK: ${DISK_USAGE}% used")
fi

# Check memory usage
MEM_AVAILABLE=$(free -m 2>/dev/null | awk '/Mem:/ {printf "%.0f", ($7/$2)*100}' || echo "N/A")
if [[ "$MEM_AVAILABLE" != "N/A" && "$MEM_AVAILABLE" -lt 15 ]]; then
  FAILED_SERVICES+=("MEMORY: only ${MEM_AVAILABLE}% available")
fi

# Send alert if anything failed
if [[ ${#FAILED_SERVICES[@]} -gt 0 ]]; then
  MSG="<b>ALERT: ${HOSTNAME}</b>%0A%0A"
  for svc in "${FAILED_SERVICES[@]}"; do
    MSG+="- ${svc}%0A"
  done
  MSG+="%0ATime: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  send_telegram "$MSG"
  echo "ALERT sent: ${FAILED_SERVICES[*]}"
  exit 1
else
  echo "OK: All services healthy ($(date '+%H:%M'))"
fi
