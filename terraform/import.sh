#!/bin/bash
# Import existing Hetzner resources into Terraform state.
#
# Prerequisites:
#   1. cp terraform.tfvars.example terraform.tfvars (fill in real values)
#   2. terraform init
#
# Get resource IDs:
#   curl -H "Authorization: Bearer $HCLOUD_TOKEN" https://api.hetzner.cloud/v1/servers
#   curl -H "Authorization: Bearer $HCLOUD_TOKEN" https://api.hetzner.cloud/v1/ssh_keys
#   curl -H "Authorization: Bearer $HCLOUD_TOKEN" https://api.hetzner.cloud/v1/firewalls
#
# Usage:
#   ./import.sh <server_id> <ssh_key_id> [firewall_id]

set -euo pipefail

SERVER_ID="${1:?Usage: ./import.sh <server_id> <ssh_key_id> [firewall_id]}"
SSH_KEY_ID="${2:?Usage: ./import.sh <server_id> <ssh_key_id> [firewall_id]}"
FIREWALL_ID="${3:-}"

echo "=== Importing Hetzner resources ==="

echo "Importing server (ID: $SERVER_ID)..."
terraform import hcloud_server.prod "$SERVER_ID"

echo "Importing SSH key (ID: $SSH_KEY_ID)..."
terraform import hcloud_ssh_key.default "$SSH_KEY_ID"

if [ -n "$FIREWALL_ID" ]; then
  echo "Importing firewall (ID: $FIREWALL_ID)..."
  terraform import hcloud_firewall.prod "$FIREWALL_ID"
else
  echo "No firewall ID — firewall will be CREATED on terraform apply"
fi

echo ""
echo "=== Done. Next steps: ==="
echo "  terraform plan   # Should show minimal changes"
echo "  terraform apply  # Only if plan looks clean"
echo ""
echo "=== To import Cloudflare DNS records: ==="
echo "  # Get record IDs:"
echo "  curl -H 'Authorization: Bearer TOKEN' \\"
echo "    'https://api.cloudflare.com/client/v4/zones/ZONE_ID/dns_records' | jq '.result[] | {id, name, type}'"
echo ""
echo "  # Then import each:"
echo "  terraform import 'cloudflare_record.root[\"mofindex\"]' ZONE_ID/RECORD_ID"
echo "  terraform import 'cloudflare_record.www[\"mofindex\"]' ZONE_ID/RECORD_ID"
