# Root A record for each domain -> VPS IP
resource "cloudflare_record" "root" {
  for_each = var.domains

  zone_id = each.value.zone_id
  name    = each.value.domain
  content = var.server_ip
  type    = "A"
  ttl     = 1       # 1 = automatic in Cloudflare
  proxied = false   # SSL terminates at Nginx/certbot, not Cloudflare

  comment = "Managed by Terraform"
}

# www CNAME for each domain -> root domain
resource "cloudflare_record" "www" {
  for_each = var.domains

  zone_id = each.value.zone_id
  name    = "www"
  content = each.value.domain
  type    = "CNAME"
  ttl     = 1
  proxied = false

  comment = "Managed by Terraform"
}
