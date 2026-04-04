resource "hcloud_ssh_key" "default" {
  name       = "jadlao@Josefs-Mac-mini.local"
  public_key = var.ssh_public_key

  lifecycle {
    ignore_changes = [public_key]
  }
}
