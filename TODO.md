# TODO

- [ ] Перейти с отдельного чарта `victoria-metrics-alert` на `victoria-metrics-k8s-stack` (встроенный vmalert): убрать `helm_release` для `victoria-metrics-alert`, дропнуть `values/vma-values.yaml` и связанные ссылки из README.md; правила и datasource на VictoriaLogs уже описаны в `values/vmks-values.yaml.tftpl`.

- [ ] Для всех values yaml (`vmks-values.yaml`, `vlc-values.yaml`, `vls-values.yaml`, `vma-values.yaml`) должны существовать шаблоны `*.yaml.tftpl` в каталоге `values/`, из которых Terraform-ресурс `helm_release` создаёт соответствующий `values yaml` через `templatefile()`. На данный момент шаблон есть только для `vmks-values.yaml.tftpl`; остальные values лежат в виде статических yaml-файлов и должны быть переведены в tftpl-форму с пробросом параметров через `local.*` / `var.*` (FQDN Grafana/Alertmanager, имя release, namespace, retention, размеры PV, ресурсы, теги Telegram и т.п.).

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
