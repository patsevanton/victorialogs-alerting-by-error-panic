locals {
  # Namespace, где живёт весь стек (VictoriaLogs, vlagent, vmks, vmalert).
  monitoring_namespace = "vmks"

  # Имя VictoriaLogs single-node и внутренний URL read-эндпоинта (:9428).
  vls_name_override = "vls"
  vls_server_url    = "http://vls-server.${local.monitoring_namespace}.svc.cluster.local:9428"

  # FQDN Grafana и Alertmanager формируются из публичного IP Traefik через sslip.io.
  grafana_fqdn      = "grafana.${local.ingress_public_ip}.sslip.io"
  alertmanager_fqdn = "alertmanager.${local.ingress_public_ip}.sslip.io"

  # ----- VictoriaLogs single-node (victoria-logs-single) -----
  # vmks ставится первым: vmServiceScrape (см. vls-values.yaml.tftpl) уводит
  # собственные метрики VictoriaLogs в vmagent/vmsingle из victoria-metrics-k8s-stack.
  vls_retention      = "14d"
  vls_storage_class  = "yc-network-ssd"
  vls_pv_size        = "20Gi"
  vls_cpu_request    = "100m"
  vls_memory_request = "128Mi"
  vls_cpu_limit      = "1"
  vls_memory_limit   = "1Gi"

  # ----- vlagent (victoria-logs-collector) -----
  vlc_name_override  = "vlc"
  vlc_cpu_request    = "50m"
  vlc_memory_request = "64Mi"
  vlc_cpu_limit      = "200m"
  vlc_memory_limit   = "256Mi"

  # ----- vmks (victoria-metrics-k8s-stack) -----
  vmks_retention = "14d"
  vmks_pv_size   = "20Gi"

  # ----- Values, отрендеренные из шаблонов *.tftpl -----
  vmks_values = templatefile("${path.module}/values/vmks-values.yaml.tftpl", {
    grafana_fqdn      = local.grafana_fqdn
    alertmanager_fqdn = local.alertmanager_fqdn
    vls_server_url    = local.vls_server_url
    vmks_retention    = local.vmks_retention
    vmks_pv_size      = local.vmks_pv_size
    telegram_chat_id  = var.telegram_chat_id
  })

  vls_values = templatefile("${path.module}/values/vls-values.yaml.tftpl", {
    vls_name_override  = local.vls_name_override
    vls_retention      = local.vls_retention
    vls_storage_class  = local.vls_storage_class
    vls_pv_size        = local.vls_pv_size
    vls_cpu_request    = local.vls_cpu_request
    vls_memory_request = local.vls_memory_request
    vls_cpu_limit      = local.vls_cpu_limit
    vls_memory_limit   = local.vls_memory_limit
  })

  vlc_values = templatefile("${path.module}/values/vlc-values.yaml.tftpl", {
    vlc_name_override  = local.vlc_name_override
    vls_server_url     = local.vls_server_url
    vlc_cpu_request    = local.vlc_cpu_request
    vlc_memory_request = local.vlc_memory_request
    vlc_cpu_limit      = local.vlc_cpu_limit
    vlc_memory_limit   = local.vlc_memory_limit
  })

  # Secret с токеном Telegram-бота. Рендерится на диск, применяется вручную
  # kubectl apply -f telegram-bot-token-secret.yaml. Токен не попадает в git
  # (terraform.tfvars в .gitignore), а в values-файл и Helm-release не входит.
  telegram_secret = templatefile("${path.module}/manifests/telegram-bot-token-secret.yaml.tftpl", {
    bot_token_b64 = base64encode(var.telegram_bot_token)
  })
}

resource "local_file" "write_vmks_values" {
  content         = local.vmks_values
  filename        = "${path.module}/values/vmks-values.yaml"
  file_permission = "0644"
}

resource "local_file" "write_vls_values" {
  content         = local.vls_values
  filename        = "${path.module}/values/vls-values.yaml"
  file_permission = "0644"
}

resource "local_file" "write_vlc_values" {
  content         = local.vlc_values
  filename        = "${path.module}/values/vlc-values.yaml"
  file_permission = "0644"
}

resource "local_file" "write_telegram_secret" {
  content         = local.telegram_secret
  filename        = "${path.module}/telegram-bot-token-secret.yaml"
  file_permission = "0600"
}
