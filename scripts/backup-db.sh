#!/bin/bash
# Backup all PostgreSQL databases
# Run via cron: 0 3 * * * /opt/infra/scripts/backup-db.sh

set -e

BACKUP_DIR="/opt/backups/postgres"
DATE=$(date +%Y-%m-%d_%H%M)
RETAIN_DAYS=7

mkdir -p "$BACKUP_DIR"

DATABASES=(
  "mof_database"
  "clinical_trials"
  "reagent_prices"
  "lab_equipment"
  "research_protocols"
  "grant_funding"
  "core_facilities"
  "plasma_donation"
  "calibration_finder"
  "reference_standards"
  "cro_directory"
  "upe_literature"
  "consciousness_directory"
  "govcontractscout"
  "govportals"
)

for DB in "${DATABASES[@]}"; do
  echo "Backing up ${DB}..."
  docker compose -f /opt/infra/prod/docker-compose.yml exec -T postgres \
    pg_dump -U "${POSTGRES_USER:-admin}" "$DB" | gzip > "${BACKUP_DIR}/${DB}_${DATE}.sql.gz"
done

# Clean up old backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +${RETAIN_DAYS} -delete

echo "Backup complete: ${BACKUP_DIR}"
