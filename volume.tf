resource "libvirt_volume" "ubuntu_24_04_ubuntu_base" {
  name = "${random_id.id.id}_ubuntu_24_04.img"
  pool = "default"

  create = {
    content = {
      format = "qcow2"
      url    = "../../images/ubuntu/noble-server-cloudimg-amd64.img"
      # url = "https://cloud-images.ubuntu.com/oracular/current/oracular-server-cloudimg-amd64.img"
      # or: url = "file:///path/to/local/image.qcow2"
    }
  }
}

resource "libvirt_volume" "ubuntu_24_04_image" {
  name     = "${random_id.id.id}_ubuntu_24_04.qcow2"
  pool     = "default"
  capacity = 10737418240 # 10 GiB

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.ubuntu_24_04_ubuntu_base.path
    format = {
      type = "qcow2"
    }
  }
}


