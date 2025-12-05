resource "libvirt_cloudinit_disk" "init" {
  name      = "cloud-init"
  user_data = local.user_data

  meta_data = yamlencode({
    instance-id    = local.hostname
    local-hostname = local.hostname
  })

  # Network config
  network_config = templatefile("${path.module}/templates/netplan.yml", {})
}

resource "libvirt_volume" "cloudinit" {
  name = "${random_id.id.id}_ubuntu_24_04_cloudinit.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.init.path
    }
  }

}