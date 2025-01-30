## Описание выполнения задания

### Задание 1

1. **Изучение проекта**  
   - Ознакомился со структурой и содержимым файлов проекта.

2. **Инициализация проекта**  
   ```bash
   terraform init
   ```

3. **Применение конфигурации**  
   ```bash
   terraform apply
   ```

4. **Скриншот входящих правил группы безопасности**  
   - После успешного создания ресурсов сделал скриншот правил входящего трафика в Yandex Cloud.  
   - Файл добавлен в репозиторий как `входящих правил «Группы безопасности» .png`.
     
![Группы безопасности](https://github.com/V3l337/ter-homeworks_03/blob/master/входящих%20правил%20«Группы%20безопасности»%20.png)

### Задание 2

#### 1. Создание двух одинаковых ВМ с использованием `count`
- Создан файл `count-vm.tf`.
- В нем описано создание двух виртуальных машин `web-1` и `web-2`:
  
  ```hcl
  resource "yandex_compute_instance" "web" {
    count = 2
    name  = "web-${count.index + 1}"
    # остальные параметры
  }
  ```

- Присвоена созданная ранее группа безопасности.

#### 2. Создание двух ВМ для баз данных с использованием `for_each`
- Создан файл `for_each-vm.tf`.
- Используется переменная `each_vm`:

  ```hcl
  variable "each_vm" {
    type = list(object({
      vm_name     = string
      cpu         = number
      ram         = number
      disk_volume = number
    }))
  }
  ```

- Виртуальные машины создаются следующим образом:

  ```hcl
  resource "yandex_compute_instance" "db" {
    for_each = { for vm in var.each_vm : vm.vm_name => vm }

    name = each.value.vm_name
    # остальные параметры
  }
  ```

#### 3. Зависимости между ресурсами
- Установлена зависимость между ресурсами:

  ```hcl
  depends_on = [yandex_compute_instance.db]
  ```

#### 4. Использование SSH-ключа
- Локальная переменная для ключа:

  ```hcl
  vms_metadata = {
  common = {
    serial_port_enable = 1
    ssh_keys           = "v3ll:ssh-ed25519 AAAAC3NzaC1l....er"
  }
  ```

- Добавлен в `metadata`:

  ```hcl
   metadata = {
    serial-port-enable = var.vms_metadata["common"].serial_port_enable
    ssh-keys           = var.vms_metadata["common"].ssh_keys
  }
  ```

#### 5. Применение конфигурации
```bash
terraform init
terraform apply
```

### Задание 3

#### 1. Создание трех одинаковых виртуальных дисков
- Файл `disk_vm.tf` содержит:
  
  ```hcl
  resource "yandex_compute_disk" "disks" {
     count = 3
     name  = "disk-${count.index + 1}"
     zone = var.default_zone
     size = 1
    # остальные параметры
  }
  ```

#### 2. Создание ВМ "storage" и подключение дисков
- Использован `dynamic`:

  ```hcl
  resource "yandex_compute_instance" "oneVM" {
    name = "storage"
    # основные параметры

    dynamic "secondary_disk" {
    for_each = toset([for disk in yandex_compute_disk.disks : disk.id])
    content {
      disk_id = secondary_disk.value
      mode    = "READ_WRITE"
    }
  }
  ```

### Задание 4

#### 1. Создание inventory-файла для Ansible
- Файл `ansible.tf` генерирует inventory-файл:

  ```hcl
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
  ```

#### 2. Применение конфигурации
```bash
terraform init
terraform apply
```

#### 3. Скриншот файла инвентаря
- Сделан скриншот получившегося файла - я добавил файл `ansible_inventory.ini`.
- Файл загружен в репозиторий.

## Завершение

- Вся работа закоммичена в ветку `terraform-03`.
- [Ссылка на коммит](https://github.com/V3l337/ter-homeworks_03).
