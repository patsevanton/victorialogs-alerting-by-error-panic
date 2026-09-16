# TODO

## Обновление YAML-конфигов в README

Начато, но не завершено. README-фрагменты разошлись с актуальными файлами
проекта (`values/*.yaml`, `manifests/*.yaml`). Что осталось сделать:

- [ ] Синхронизировать `_stream_fields` и `ignore_fields` Vector в README с
  `values/vector-values.yaml`: актуальный набор
  `kubernetes.pod_namespace,kubernetes.container_name` (без `kubernetes.pod_name`),
  `ignore_fields` из файла убран.

- [ ] Показать в Шаге 1 полный `vmks-values.yaml`: `grafana` (plugins/ingress),
  `defaultDatasources` (VictoriaLogs), отключение control-plane
  (`kubeControllerManager`/`kubeScheduler`/`kubeEtcd`/`defaultRules.groups`),
  `vmalert`. Решено показывать полный values.

- [ ] Актуализировать блок `alertmanager` в Шаге 6: добавить `secrets`,
  `ingress`, `global.http_config.proxy_from_environment`; НЕ упоминать
  mihomo-прокси (`extraEnvs`) — правило проекта запрещает его в README.

- [ ] Добавить `annotations` (summary/description) к правилам `GolangFatalLog`
  и `GolangErrorLog` в Шаге 5 — в `manifests/vmalert-rules-golang.yaml` они уже
  есть, в README отсутствуют.

- [ ] Добавить полный YAML-блок `VMRule` nuxt в Шаг 5
  (`manifests/vmalert-rules-nuxt.yaml`) вместо bullet-списка.

- [ ] Отразить ingress vmui в `values/vls-values.yaml` (незакоммиченное
  изменение `vls-values.yaml.tftpl`: `server.ingress` на `vmui_fqdn`).

- [ ] Перепроверить ingress vmui VictoriaLogs: в output `vmui_url` указан путь
  `/select/vmui` (на корне `/` VictoriaLogs отдаёт 404). Проверить, что ingress
  реально опубликован и vmui открывается по `http://vls.<ip>.sslip.io/select/vmui`.

## Убрать мусорные label в Vector

- [ ] Убрать мусорные label типа `file` или `container_id` из Vector-конфигурации
  (`values/vector-values.yaml`).
