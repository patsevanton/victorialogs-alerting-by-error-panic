# TODO

- [ ] Обновить traefik с 41.3.0 до 41.4.0 (namespace `ingress-контроллер`).

- [x] Перейти с отдельного чарта `victoria-metrics-alert` на `victoria-metrics-k8s-stack` (встроенный vmalert): дропнуть `values/vma-values.yaml` и связанные ссылки из README.md; правила и datasource на VictoriaLogs описаны в `values/vmks-values.yaml.tftpl`.

- [x] Для всех values yaml (`values/vmks-values.yaml`, `values/vlc-values.yaml`, `values/vls-values.yaml`) существуют шаблоны `*.yaml.tftpl` в каталоге `values/`, из которых Terraform через `templatefile()` (`monitoring.tf`) генерирует соответствующий `values yaml` на диск (`local_file`) рядом с шаблоном. Параметры пробрасываются через `local.*` / `var.*` (FQDN Grafana/Alertmanager, имя release, namespace, retention, размеры PV, ресурсы, теги Telegram).

Пример манифеста для vmalert через `kind: VMRule` (Operator вместо ConfigMap):

```yaml
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMRule
metadata:
  name: golang-app-vmrule
  namespace: vmks
spec:
  groups:
    - name: golang-app
      type: vlogs
      interval: 1m
      rules:
        - alert: GolangPanicDetected
          # "panic:" есть и у явного panic("..."), и у runtime-паник
          # (nil pointer dereference, index out of range) — ловим все разом.
          expr: |
            kubernetes.pod_labels.app:=golang-app
              | _msg:~"panic:"
              | stats by (kubernetes.pod_name) count() as panics
              | filter panics:>0
          for: 1m
          labels:
            severity: critical
            app: golang-app
          annotations:
            summary: "panic в golang-app"
            description: |
              Паник у пода {{ index $labels "kubernetes.pod_name" }} за 1m: {{ $value }}.
              Логи: Kubernetes -> vlagent -> VictoriaLogs.
```
