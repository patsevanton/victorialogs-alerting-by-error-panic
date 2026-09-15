locals {
  # Namespace стека VictoriaMetrics/VictoriaLogs (vmks, vmalert). Vector — в ns vector.
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

  # ----- Vector (helm chart vector, role Agent) -----
  # Вместо vlagent: https://github.com/VictoriaMetrics/VictoriaLogs/issues/1790

  # ----- Values, отрендеренные из шаблонов *.tftpl -----
  vmks_values = templatefile("${path.module}/values/vmks-values.yaml.tftpl", {
    grafana_fqdn      = local.grafana_fqdn
    alertmanager_fqdn = local.alertmanager_fqdn
    vls_server_url    = local.vls_server_url
    telegram_chat_id  = var.telegram_chat_id
  })

  vls_values = templatefile("${path.module}/values/vls-values.yaml.tftpl", {
    vls_name_override = local.vls_name_override
  })

  vector_values = templatefile("${path.module}/values/vector-values.yaml.tftpl", {
    vls_server_url = local.vls_server_url
  })

  # Secret с токеном Telegram-бота. Рендерится на диск, применяется вручную
  # kubectl apply -f telegram-bot-token-secret.yaml. Токен не попадает в git
  # (terraform.tfvars в .gitignore), а в values-файл и Helm-release не входит.
  telegram_secret = templatefile("${path.module}/manifests/telegram-bot-token-secret.yaml.tftpl", {
    bot_token_b64 = base64encode(var.telegram_bot_token)
  })

  # Манифест mihomo-прокси (обход блокировки api.telegram.org). URL VLESS-подписки
  # приходит из переменной vless_subscription_url (sensitive, в git не попадает)
  # и подставляется в Secret mihomo-config. Рендерится в manifests/mihomo-proxy.yaml.
  mihomo_manifest = templatefile("${path.module}/manifests/mihomo-proxy.yaml.tftpl", {
    vless_subscription_url = var.vless_subscription_url
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

resource "local_file" "write_vector_values" {
  content         = local.vector_values
  filename        = "${path.module}/values/vector-values.yaml"
  file_permission = "0644"
}

resource "local_file" "write_telegram_secret" {
  content         = local.telegram_secret
  filename        = "${path.module}/telegram-bot-token-secret.yaml"
  file_permission = "0600"
}

resource "local_file" "write_mihomo_manifest" {
  content         = local.mihomo_manifest
  filename        = "${path.module}/manifests/mihomo-proxy.yaml"
  file_permission = "0600"
}
