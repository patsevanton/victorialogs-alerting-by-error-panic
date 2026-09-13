# Правила проекта

## README

- Не упоминать mihomo-прокси (обход блокировки `api.telegram.org`) в README — это внутренняя деталь реализации и в публичном описании не нужна. В коде (`values/vmks-values.yaml.tftpl`, `manifests/mihomo-proxy.yaml.tftpl`) прокси остаётся.

## Подготовка

Нужны Terraform, `yc` CLI, `kubectl` и `helm`. Инфраструктуру создаёт Terraform: сеть с NAT-шлюзом, managed-кластер Kubernetes и Traefik. Он же рендерит values-файлы (`values/*.yaml`) из шаблонов `*.tftpl` и манифесты с секретами.

Секреты задаются в `terraform.tfvars` (файл в `.gitignore`, в git не попадает):

```hcl
folder_id              = "b1gxxxxxxxxxxxxxxxx"
telegram_bot_token     = "123456789:ABCdefGhI-jklMnoPQRstuVwxYZ"
telegram_chat_id       = -1001234567890
vless_subscription_url = "https://sub.example.com/ВАША_VLESS_ПОДПИСКА"
```

- `telegram_bot_token` — токен бота: попадает в Secret `telegram-bot-token`, который монтируется в Alertmanager (Шаг 6);
- `telegram_chat_id` — ID чата/группы (отрицательное число для групп): подставляется в values Alertmanager;
- `vless_subscription_url` — URL VLESS-подписки для исходящего трафика Alertmanager: подставляется в сгенерированный манифест.

```bash
cp terraform.tfvars.example terraform.tfvars   # заполнить своими значениями
terraform init
terraform apply
```

`terraform apply` создаёт кластер и Traefik, а также рендерит на диск:

- `values/vmks-values.yaml`, `values/vls-values.yaml`, `values/vlc-values.yaml`;
- `telegram-bot-token-secret.yaml`;
- `manifests/mihomo-proxy.yaml`.

Secret с токеном и mihomo-прокси должны существовать в кластере **до** `helm install vmks`: Alertmanager монтирует Secret при старте, а Telegram доступен только через прокси. Secret объявлен в namespace `vmks`, который создаётся на Шаге 1 (`--create-namespace`), поэтому до применения Secret создаём namespace вручную. Подключаемся к кластеру и применяем их:

```bash
eval "$(terraform output -raw k8s_cluster_credentials_command)"
kubectl create namespace vmks
kubectl apply -f telegram-bot-token-secret.yaml
kubectl apply -f manifests/mihomo-proxy.yaml
```

Далее — шаги 1–6 из README. Порядок строгий: Шаг 1 (vmks) создаёт CRD `VMAlert`/`VMRule` и оператор, Шаг 2 (VictoriaLogs) — datasource, и только в конце Шага 3 применяем `manifests/vmalert-logs.yaml` и `manifests/vmalert-rules.yaml`. Приложения (Шаг 4) поднимаются уже при готовом алертинге.

