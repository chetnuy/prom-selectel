######### Настройки провайдеров  #########

# Настройки подключения провайдера openstack
variable "auth_url" {
  default = "https://api.selvpc.ru/identity/v3"
}
variable "domain_name" {
  default = ""
}
variable "tenant_id" {
  default = ""
}
variable "user_name" {
  default = ""
}
variable "password" {
  default = ""
}

######### Конфигурация вм  #########

# Количество воркеров
variable "node_count" {
  default = "4"
}
# Регион Облачной платформы
variable "region" {
  default = "ru-3"
}
# Значение SSH-ключа для доступа к облачному серверу
variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCLHhhOrAmzDqL1pwJGDvy+Nn4SivRglwUR7ByvsCLXS6k07KOrloUkDyeH1w2Bf1VUuUUijA3ifMAB78kdzpFoFVLMtnOlOnpblqMULxEyhC1eVtUGpBjq9FTK2G/LUdGQBlpqjV3S9/UX6Dya8hoxsDRcTueW+WZ3AadueUmcQmSr+scRYvXwminLYHjIYBYn8+k9e8yBy6odw0ReSxY3u8AasP0CVqrN/JPO5VfhYO/FOP4zuU+UHuKx9YPDaxe8MFIb+3r8iO+UfZ4V1TCTfS2vlJw6JIirqxyuNi91rP0Die2Yugiw+t0SofcK5EOf4q10MilwNZEUk583zC2mSlR0ypuU80/0SbYBxZNfBboNRUv5mRfeGar5KAwGY227soN84FBr8UxUhGEy6uJVsC+Tc3MC0Le6RWwCnmzaSAeMux5HKgxKZd70cX005qxF/wl8+jwgojuxySMGx0xmSGeXoj5OtsUDkcvBG8xqLOzGntnVE0IUNwsw27fbGM= user@host"
}
# Зона доступности
variable "az_zone" {
  default = "ru-3b"
}
# Тип сетевого диска, из которого создается сервер
variable "volume_type" {
  default = "fast.ru-3b"
}
# CIDR подсети
variable "subnet_cidr" {
  default = "10.10.0.0/24"
}
