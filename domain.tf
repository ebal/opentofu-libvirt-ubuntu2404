# Basic VM configuration
resource "libvirt_domain" "example" {
  name        = "example"
  memory      = 2048
  memory_unit = "MiB"
  vcpu        = 1
  type        = "kvm"

  autostart = true # Domain will automatically start on host boot

  os = {
    type        = "hvm"
    arch        = "x86_64"
    machine     = "q35"
    boot        = "hd"
    kernel_args = "console=ttyS0 root=/dev/vda1"
  }

  features = {
    "acpi" = true,
    "apic" = {},
    "pae"  = true
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.ubuntu_24_04_image.name
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
      driver = {
        name = "qemu"
        type = "qcow2"
      }
      },
      {
        device = "cdrom"
        source = {
          file = {
            pool = "default"
            file = libvirt_volume.cloudinit.path
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
      }
    ]

    consoles = [{
      type = "pty"
      source = {
        path = "/dev/pts/0"
      }
      target = {
        type = "serial"
        # port omitted - let libvirt handle it
      }
      },
      {
        type = "pty"
        source = {
          path = "/dev/pts/1"
        }
        target = {
          type = "virtio"
          # port omitted - let libvirt handle it
        }
      },
    ]

    channels = [
      {
        source = {
          unix = {}
        }
        target = {
          virt_io = {
            name = "org.qemu.guest_agent.0"
          }
        }
      }
    ]

    interfaces = [{
      model = {
        type = "virtio"
      }
      source = {
        network = {
          network = "default"
        }
        wait_for_ip = {
          timeout = 300     # seconds
          source  = "lease" # or "agent" or "any"
        }
      }
    }]

  }

  depends_on = [libvirt_volume.ubuntu_24_04_image, libvirt_volume.cloudinit]

  provisioner "local-exec" {
    when    = create
    command = "sudo virsh start ${libvirt_domain.example.name}"
  }

}


