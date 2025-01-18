output "debug_web_vms" {
  value = [for vm in yandex_compute_instance.VM : vm.network_interface]
}

output "debug_db_vms" {
  value = [for _, db in yandex_compute_instance.db : db.network_interface]
}

output "debug_storage_vms" {
  value = yandex_compute_instance.oneVM.network_interface
}
