resource "hcloud_server" "prod" {
  name        = var.server_name
  server_type = var.server_type
  location    = var.server_location
  image       = var.server_image

  ssh_keys    = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.prod.id]

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [image]
  }
}
