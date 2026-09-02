locals {
  network_id = yandex_vpc_network.vlogs.id

  subnet_b_id   = yandex_vpc_subnet.vlogs-b.id
  subnet_d_id   = yandex_vpc_subnet.vlogs-d.id
  subnet_e_id   = yandex_vpc_subnet.vlogs-e.id
  subnet_b_zone = yandex_vpc_subnet.vlogs-b.zone
  subnet_d_zone = yandex_vpc_subnet.vlogs-d.zone
  subnet_e_zone = yandex_vpc_subnet.vlogs-e.zone

  # Публичный IP балансировщика Traefik. FQDN сервисов формируются через sslip.io.
  ingress_public_ip = yandex_vpc_address.addr.external_ipv4_address[0].address
}
