locals {
  vmks_values = templatefile("${path.module}/values/vmks-values.yaml.tftpl", {
    ingress_public_ip = local.ingress_public_ip
    telegram_chat_id  = var.telegram_chat_id
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
  filename        = "${path.module}/vmks-values.yaml"
  file_permission = "0644"
}

resource "local_file" "write_telegram_secret" {
  content         = local.telegram_secret
  filename        = "${path.module}/telegram-bot-token-secret.yaml"
  file_permission = "0600"
}
