resource "local_file" "ansible_inventory" {
  filename = "${abspath(path.module)}/ansible_inventory.ini"

  content = templatefile("${path.module}/inventory.tpl", {
    web_vms = [for vm in yandex_compute_instance.VM : {
      name              = vm.name,
      network_interface = vm.network_interface
    }],
    db_vms = [for _, db in yandex_compute_instance.db : {
      name              = db.name,
      network_interface = db.network_interface
    }],
    storage_vms = {
      name              = yandex_compute_instance.oneVM.name,
      network_interface = yandex_compute_instance.oneVM.network_interface
    }
  })
}
