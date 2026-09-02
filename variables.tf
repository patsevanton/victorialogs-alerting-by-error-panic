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
