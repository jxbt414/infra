output "server_ip" {
  description = "Public IPv4 address of the production VPS"
  value       = hcloud_server.prod.ipv4_address
}

output "server_status" {
  description = "Current server status"
  value       = hcloud_server.prod.status
}

output "server_id" {
  description = "Hetzner server ID"
  value       = hcloud_server.prod.id
}

output "firewall_id" {
  description = "Hetzner firewall ID"
  value       = hcloud_firewall.prod.id
}

output "dns_records" {
  description = "DNS A records pointing to the VPS"
  value = {
    for k, v in cloudflare_record.root : k => {
      domain = var.domains[k].domain
      ip     = v.content
    }
  }
}
