resource "yandex_compute_disk" "disks" {
  count = 3
  name  = "disk-${count.index + 1}"

  zone = var.default_zone
  size = 1
}

resource "yandex_compute_instance" "oneVM" {
  name = "storage"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = var.IMG_family
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    # security_group_ids = [yandex_vpc_security_group.example.id]
    nat = true
  }

  metadata = {
    serial-port-enable = var.vms_metadata["common"].serial_port_enable
    ssh-keys           = var.vms_metadata["common"].ssh_keys
  }

  dynamic "secondary_disk" {
    for_each = toset([for disk in yandex_compute_disk.disks : disk.id])

    content {
      disk_id = secondary_disk.value
      mode    = "READ_WRITE"
    }
  }
}
