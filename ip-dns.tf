# Внешний IP-адрес для LoadBalancer Traefik.
resource "yandex_vpc_address" "addr" {
  name = "vlogs-pip"

  external_ipv4_address {
    zone_id = local.subnet_d_zone
  }
}

# Пауза перед удалением публичного IP при terraform destroy:
# LoadBalancer, создаваемый cloud-controller-manager через Service Traefik,
# освобождает адрес не мгновенно после удаления кластера/helm-релиза.
resource "time_sleep" "wait_lb_release" {
  destroy_duration = "60s"

  depends_on = [
    yandex_vpc_address.addr,
  ]
}
