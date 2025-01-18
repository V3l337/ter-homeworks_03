[webservers]
%{ for web_vm in web_vms ~}
${web_vm.name} ansible_host=${web_vm.network_interface[0].nat_ip_address}
%{ endfor ~}

[databases]
%{ for db_vm in db_vms ~}
${db_vm.name} ansible_host=${db_vm.network_interface[0].nat_ip_address}
%{ endfor ~}

[storage]
%{ if storage_vms != null ~}
${storage_vms.name} ansible_host=${storage_vms.network_interface[0].nat_ip_address}
%{ endif ~}
