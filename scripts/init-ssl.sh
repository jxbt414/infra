#!/bin/bash
# First-time SSL setup — run AFTER DNS is pointed to VPS
# Requests certs for all domains via Let's Encrypt
#
# Before running:
# 1. Point all domains to VPS IP in Cloudflare (DNS only, not proxied)
# 2. Ensure port 80 is open
# 3. Start nginx with HTTP-only configs first

set -e

EMAIL="${1:-your-email@example.com}"

DOMAINS=(
  "mofindex.com"
  "clinicaltrialsfinder.org"
  "upeliterature.com"
  "tgaintel.com"
  "celllinefinder.com"
  "labsoftware.directory"
  "referencestandards.org"
  "labpricecheck.com"
)

for DOMAIN in "${DOMAINS[@]}"; do
  echo "=== Requesting cert for ${DOMAIN} ==="
  docker compose -f prod/docker-compose.yml run --rm certbot \
    certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    -d "$DOMAIN" \
    -d "www.$DOMAIN"
done

echo "All certs issued. Restarting nginx..."
docker compose -f prod/docker-compose.yml restart nginx
echo "Done."
