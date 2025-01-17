resource "yandex_compute_instance" "db" {
  for_each = { for vm in var.each_VM : vm.vm_name => vm }

  name = each.value.vm_name

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.IMG_family
      size     = each.value.disk_volume
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
}
