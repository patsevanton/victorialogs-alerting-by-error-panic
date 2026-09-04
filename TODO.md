# TODO

- [ ] Обновить traefik с 41.3.0 до 41.4.0 (namespace `ingress-контроллер`).

- [x] Перейти с отдельного чарта `victoria-metrics-alert` на `victoria-metrics-k8s-stack` (встроенный vmalert): дропнуть `values/vma-values.yaml` и связанные ссылки из README.md; правила и datasource на VictoriaLogs описаны в `values/vmks-values.yaml.tftpl`.

- [x] Для всех values yaml (`values/vmks-values.yaml`, `values/vlc-values.yaml`, `values/vls-values.yaml`) существуют шаблоны `*.yaml.tftpl` в каталоге `values/`, из которых Terraform через `templatefile()` (`monitoring.tf`) генерирует соответствующий `values yaml` на диск (`local_file`) рядом с шаблоном. Параметры пробрасываются через `local.*` / `var.*` (FQDN Grafana/Alertmanager, имя release, namespace, retention, размеры PV, ресурсы, теги Telegram).
