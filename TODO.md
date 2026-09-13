# TODO

- [x] Решить задачу выбора кастомных PromQL-правил встроенным `vmalert`.
  Встроенный `vmalert` больше не ограничен лейблом
  `app.kubernetes.io/managed-by: sync-job`: вместо этого он берёт все `VMRule`,
  кроме LogsQL-правил, через «обратный» selector (`type NotIn logs-to-metrics`).
  Кастомный PromQL-`VMRule` теперь подхватывается сам, без ручных лейблов
  (сделано по образцу `apps/victoria-metrics` в infra-v3, без vmauth).

- [ ] Если не получится надёжно разделить PromQL и LogsQL одним встроенным
  `vmalert` (например, кастомный PromQL-`VMRule` всё ещё уходит в отдельный
  `vmalert-logs` или наоборот), добавить `vmauth`, как это сделано для
  `vscluster` в infra-v3 (`apps/vlcluster/vmauth-logs.yaml`), и развести запросы
  по префиксу пути:
  ```yaml
  unauthorizedUserAccessSpec:
    url_map:
      - src_paths: ["/api/v1/query.*"]
        url_prefix: ["http://vmsingle-vmks-victoria-metrics-k8s-stack.vmks.svc.cluster.local:8428"]
      - src_paths: ["/select/logsql/.*"]
        url_prefix: ["http://vls-server.vmks.svc.cluster.local:9428"]
  ```
  Тогда один `VMAlert` с `datasource.url` на `vmauth:8427` сможет исполнять и
  PromQL, и LogsQL (группа с `type: vlogs` пойдёт в VictoriaLogs, обычная —
  в VictoriaMetrics).