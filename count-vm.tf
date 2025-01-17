resource "yandex_compute_instance" "VM" {
  count = 2
  name  = "web-${count.index + 1}"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id  = var.IMG_family
      size    = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat                = true
  }

  metadata = {
    serial-port-enable = var.vms_metadata["common"].serial_port_enable
    ssh-keys           = var.vms_metadata["common"].ssh_keys
  }
  depends_on = [yandex_compute_instance.db]
}

