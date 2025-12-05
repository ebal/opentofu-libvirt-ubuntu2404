# Local variables
locals {
  hostname = "athens"        # Set hostname
  timezone = "Europe/Athens" # Set timezone

  # Set GitHub user for SSH keys
  gh_user  = "ebal" # Set GitHub user
  ssh_port = 54322  # Set desired port

  # Libvirt VM specifications
  # cloud_image should point to a valid cloud image file path
  cloud_image = "../../images/ubuntu/noble-server-cloudimg-amd64.img"

  # Virtual Machines specifications
  vol_size = 10 * 1024 * 1024 * 1024 # The disk volume size of the VM, eg. 10G
  vcpu     = 1                       # How many virtual CPUs the VM will have
  vmem     = 2048                    # How RAM will VM have will have

  # hardened sshd_config template
  sshd_config = templatefile("${path.module}/templates/sshd_config", {
    gh_user  = local.gh_user
    sshdport = local.ssh_port
  })

  # Cleanup script to remove uncessary packages on first boot
  cleanup = templatefile("${path.module}/templates/cleanup.sh", {})

  # Render network_config templates using native templatefile()
  network_config = templatefile("${path.module}/templates/netplan.yml", {})

  # Render user_data templates using native templatefile()
  user_data = templatefile("${path.module}/templates/user-data.yml", {
    hostname    = local.hostname
    sshdport    = local.ssh_port
    timezone    = local.timezone
    gh_user     = local.gh_user
    sshd_config = indent(6, local.sshd_config)
    cleanup     = indent(6, local.cleanup)
  })

}
