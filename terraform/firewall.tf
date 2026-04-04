resource "hcloud_firewall" "prod" {
  name = "prod-firewall"

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    description = "SSH access"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    description = "HTTP (certbot ACME + redirect)"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    description = "HTTPS"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }
}
