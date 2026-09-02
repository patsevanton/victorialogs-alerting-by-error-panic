# Сеть VPC.
resource "yandex_vpc_network" "vlogs" {
  name = "vpc"
}

# Подсети в трёх зонах отказоустойчивости.
resource "yandex_vpc_subnet" "vlogs-b" {
  v4_cidr_blocks = ["10.0.1.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vlogs.id
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "vlogs-d" {
  v4_cidr_blocks = ["10.0.2.0/24"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.vlogs.id
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "vlogs-e" {
  v4_cidr_blocks = ["10.0.3.0/24"]
  zone           = "ru-central1-e"
  network_id     = yandex_vpc_network.vlogs.id
  route_table_id = yandex_vpc_route_table.rt.id
}

# NAT-шлюз для исходящего трафика из приватных подсетей.
resource "yandex_vpc_gateway" "nat" {
  name = "nat-gw"
  shared_egress_gateway {}
}

# Таблица маршрутизации: весь исходящий трафик (0.0.0.0/0) через NAT-шлюз.
resource "yandex_vpc_route_table" "rt" {
  name       = "rt-nat"
  network_id = yandex_vpc_network.vlogs.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}
