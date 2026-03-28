#!/bin/bash
# Deploy to Hetzner VPS
# Usage: ./scripts/deploy.sh [site-name]
# Without args: pulls and restarts all services
# With args: pulls and restarts only the specified site

set -e

VPS_HOST="${VPS_HOST:-root@your-vps-ip}"
COMPOSE_FILE="prod/docker-compose.yml"
REMOTE_DIR="/opt/infra"

echo "Deploying to ${VPS_HOST}..."

if [ -n "$1" ]; then
  # Deploy single site
  echo "Pulling and restarting: $1"
  ssh "$VPS_HOST" "cd ${REMOTE_DIR} && docker compose -f ${COMPOSE_FILE} pull $1 && docker compose -f ${COMPOSE_FILE} up -d $1"
else
  # Deploy all
  echo "Pulling and restarting all services..."
  ssh "$VPS_HOST" "cd ${REMOTE_DIR} && docker compose -f ${COMPOSE_FILE} pull && docker compose -f ${COMPOSE_FILE} up -d && docker image prune -f"
fi

echo "Deploy complete."
