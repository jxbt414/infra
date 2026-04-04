# Terraform — Production Infrastructure

Infrastructure as Code for a Hetzner Cloud VPS running 15 production web applications with Cloudflare DNS.

## What Terraform Manages

| Resource | Provider | Description |
|----------|----------|-------------|
| VPS server | Hetzner | CX22, Ubuntu 22.04, Falkenstein DC |
| SSH key | Hetzner | Public key for server access |
| Firewall | Hetzner | Ports 22, 80, 443 |
| DNS records | Cloudflare | 15 domains × 2 records (A + www CNAME) |

## What Terraform Does NOT Manage

Docker Compose, application containers, Nginx config, SSL certificates, PostgreSQL, CI/CD pipelines. Those live in `../prod/` and are deployed via GitHub Actions.

This is a deliberate boundary: Terraform provisions infrastructure, Docker Compose runs applications.

## Architecture

```
                 Cloudflare DNS (15 domains)
                          |
                          v
                +-------------------+
                |  Hetzner VPS      |
                |  CX22 / Ubuntu    |
                |                   |
                |  Firewall:        |
                |  22, 80, 443      |
                +-------------------+
                          |
               Docker Compose (not TF)
                          |
           +---------+---------+---------+
           | Nginx   | PG 16   | 15 Apps |
           | + SSL   |         | (GHCR)  |
           +---------+---------+---------+
```

## Quick Start

```bash
# 1. Install Terraform
brew install terraform

# 2. Configure
cp terraform.tfvars.example terraform.tfvars
# Fill in: hcloud_token, cloudflare_api_token, ssh_public_key, zone IDs

# 3. Initialize
terraform init

# 4. Import existing resources (don't recreate!)
chmod +x import.sh
./import.sh <server_id> <ssh_key_id> [firewall_id]

# 5. Verify — should show zero or minimal changes
terraform plan

# 6. Apply (only if plan is clean)
terraform apply
```

## Getting Resource IDs

**Hetzner** (create API token in Cloud Console → Security → API Tokens):
```bash
export HCLOUD_TOKEN="your-token"
curl -s -H "Authorization: Bearer $HCLOUD_TOKEN" https://api.hetzner.cloud/v1/servers | jq '.servers[] | {id, name, server_type: .server_type.name}'
curl -s -H "Authorization: Bearer $HCLOUD_TOKEN" https://api.hetzner.cloud/v1/ssh_keys | jq '.ssh_keys[] | {id, name}'
curl -s -H "Authorization: Bearer $HCLOUD_TOKEN" https://api.hetzner.cloud/v1/firewalls | jq '.firewalls[] | {id, name}'
```

**Cloudflare** (create API token with DNS edit permissions):
```bash
export CF_TOKEN="your-token"
curl -s -H "Authorization: Bearer $CF_TOKEN" "https://api.cloudflare.com/client/v4/zones" | jq '.result[] | {id, name}'
```

## Adding a New Domain

1. Add entry to `domains` map in `terraform.tfvars`
2. Run `terraform plan` to preview
3. Run `terraform apply` to create DNS records

## File Structure

```
terraform/
├── main.tf                  # Provider versions and config
├── variables.tf             # Variable declarations
├── terraform.tfvars.example # Template (committed, no secrets)
├── server.tf                # hcloud_server (prevent_destroy)
├── ssh_key.tf               # hcloud_ssh_key
├── firewall.tf              # hcloud_firewall rules
├── dns.tf                   # Cloudflare A + CNAME records (for_each)
├── outputs.tf               # Server IP, status, DNS summary
├── import.sh                # One-shot import for existing resources
└── README.md                # This file
```

## Design Decisions

- **Flat structure**: Single VPS doesn't need modules or workspaces
- **`prevent_destroy`**: Server lifecycle guard — `terraform destroy` won't nuke production
- **`for_each` on domains**: 30 DNS records from a single map, zero copy-paste
- **`proxied = false`**: SSL terminates at Nginx/certbot, not Cloudflare proxy
- **Local state**: Single operator — remote backend is overhead without a team
- **No provisioners**: Server config is handled by scripts and CI/CD, not Terraform
