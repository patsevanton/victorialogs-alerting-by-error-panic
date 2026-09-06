variable "folder_id" {
  type        = string
  description = "Yandex Cloud folder id"
}

variable "telegram_bot_token" {
  type        = string
  description = "Токен Telegram-бота вида 123456789:ABCdefGhI-jklMnoPQRstuVwxYZ"
  sensitive   = true
}

variable "telegram_chat_id" {
  type        = number
  description = "ID чата/группы Telegram, куда отправляются алерты (отрицательное число для групп). Alertmanager ожидает int"
}

variable "vless_subscription_url" {
  type        = string
  description = "URL VLESS-подписки для mihomo (обход блокировки api.telegram.org из Yandex Cloud)"
  sensitive   = true
}
