######### Инициализация Terraform и конфигурации провайдера #########

terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

provider "openstack" {
  auth_url    = var.auth_url
  domain_name = var.domain_name
  tenant_id   = var.tenant_id
  user_name   = var.user_name
  password    = var.password
  region      = var.region
}


######### Общие настройки кластера #########

# Создание SSH-ключа
resource "openstack_compute_keypair_v2" "key_tf" {
  name       = "key_tf2"
  region     = var.region
  public_key = var.public_key
}

# Запрос ID external-network по имени
data "openstack_networking_network_v2" "external_net" {
  name = "external-network"
}

# Создание роутера
resource "openstack_networking_router_v2" "router_tf" {
  name                = "router_tf"
  external_network_id = data.openstack_networking_network_v2.external_net.id
}

# Создание сети
resource "openstack_networking_network_v2" "network_tf" {
  name = "network_tf"
}

# Создание подсети 
resource "openstack_networking_subnet_v2" "subnet_tf" {
  network_id = openstack_networking_network_v2.network_tf.id
  name       = "subnet_tf"
  cidr       = var.subnet_cidr
}

# Подключение роутера к подсети
resource "openstack_networking_router_interface_v2" "router_interface_tf" {
  router_id = openstack_networking_router_v2.router_tf.id
  subnet_id = openstack_networking_subnet_v2.subnet_tf.id
}

# Поиск ID образа (из которого будет создан сервер) по его имени
data "openstack_images_image_v2" "ubuntu_image" {
  most_recent = true
  visibility  = "public"
  name        = "Ubuntu 20.04 LTS 64-bit"
}

# Создание уникального имени флейвора
resource "random_string" "random_name" {
  length  = 16
  special = false
}

# Создание конфигурации вм с 1 ГБ RAM и 1 vCPU
# Параметр disk = 0  делает сетевой диск загрузочным
resource "openstack_compute_flavor_v2" "flavor" {
  name      = "vm-${random_string.random_name.result}"
  ram       = "1024"
  vcpus     = "1"
  disk      = "0"
  is_public = "false"
}

#########  Настройкa сервера  #########

# Создание сетевого загрузочного диска для сервера
resource "openstack_blockstorage_volume_v3" "volume_server" {
  name                 = "volume-for-server"
  size                 = "7"
  image_id             = data.openstack_images_image_v2.ubuntu_image.id
  volume_type          = var.volume_type
  availability_zone    = var.az_zone
  enable_online_resize = true
  lifecycle {
    ignore_changes = [image_id]
  }
}

# Создание вм сервера
resource "openstack_compute_instance_v2" "server" {
  name              = "server"
  flavor_id         = openstack_compute_flavor_v2.flavor.id
  key_pair          = openstack_compute_keypair_v2.key_tf.id
  availability_zone = var.az_zone
  network {
    uuid = openstack_networking_network_v2.network_tf.id
  }
  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_server.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }
  vendor_options {
    ignore_resize_confirmation = true
  }
  lifecycle {
    ignore_changes = [image_id]
  }
}

# Создание плавающего адреса для сервера
resource "openstack_networking_floatingip_v2" "server_fip" {
  pool = "external-network"
}

# Привязка плавающего адреса к серверу
resource "openstack_compute_floatingip_associate_v2" "server_fip" {
  floating_ip = openstack_networking_floatingip_v2.server_fip.address
  instance_id = openstack_compute_instance_v2.server.id
}

#########  Настройкa нод  #########

# Создание сетевого загрузочного диска для нод
resource "openstack_blockstorage_volume_v3" "volume_node" {
  count                = var.node_count
  name                 = "volume-for-node-${count.index + 1}"
  size                 = "7"
  image_id             = data.openstack_images_image_v2.ubuntu_image.id
  volume_type          = var.volume_type
  availability_zone    = var.az_zone
  enable_online_resize = true
  lifecycle {
    ignore_changes = [image_id]
  }
}

# Создание вм нод
resource "openstack_compute_instance_v2" "node" {
  count             = var.node_count
  name              = "node${count.index + 1}"
  flavor_id         = openstack_compute_flavor_v2.flavor.id
  key_pair          = openstack_compute_keypair_v2.key_tf.id
  availability_zone = var.az_zone
  network {
    uuid = openstack_networking_network_v2.network_tf.id
  }
  block_device {
    uuid             = "${openstack_blockstorage_volume_v3.volume_node[count.index].id}"
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }
  vendor_options {
    ignore_resize_confirmation = true
  }
  lifecycle {
    ignore_changes = [image_id]
  }
}
