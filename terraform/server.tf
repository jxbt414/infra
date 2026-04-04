resource "hcloud_server" "prod" {
  name        = var.server_name
  server_type = var.server_type
  location    = var.server_location
  image       = var.server_image

  ssh_keys = [hcloud_ssh_key.default.id]
  backups  = true

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [image, ssh_keys, firewall_ids]
  }
}
