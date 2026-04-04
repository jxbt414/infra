resource "hcloud_ssh_key" "default" {
  name       = "jadlao-macbook"
  public_key = var.ssh_public_key

  labels = {
    managed_by = "terraform"
  }
}
