#!/bin/bash
# Usage: ./scripts/add-site.sh <site-name> <domain>
# Example: ./scripts/add-site.sh clinical-trial-matching trials.local

set -e

SITE_NAME=$1
DOMAIN=${2:-"${SITE_NAME}.local"}

if [ -z "$SITE_NAME" ]; then
  echo "Usage: ./scripts/add-site.sh <site-name> [domain]"
  exit 1
fi

MANIFEST_DIR="homelab/manifests/base/apps/${SITE_NAME}"

if [ -d "$MANIFEST_DIR" ]; then
  echo "Site ${SITE_NAME} already exists at ${MANIFEST_DIR}"
  exit 1
fi

echo "Creating K8s manifests for ${SITE_NAME}..."

mkdir -p "$MANIFEST_DIR"

for file in templates/k8s-app/*.yaml; do
  sed -e "s/SITE_NAME/${SITE_NAME}/g" -e "s/SITE_DOMAIN/${DOMAIN}/g" "$file" > "${MANIFEST_DIR}/$(basename $file)"
done

echo "Created manifests at ${MANIFEST_DIR}/"
echo ""
echo "Next steps:"
echo "  1. Copy templates/nextjs/Dockerfile to your app directory"
echo "  2. Add output: 'standalone' to your next.config.ts"
echo "  3. Add the site to homelab/manifests/overlays/homelab/kustomization.yaml"
echo "  4. Create secret: kubectl create secret generic ${SITE_NAME}-secrets --from-literal=DATABASE_URL=<url>"
echo "  5. Apply: kubectl apply -k manifests/overlays/homelab/"
