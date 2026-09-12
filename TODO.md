# TODO

- [ ] Решить задачу выбора кастомных PromQL-правил встроенным `vmalert`.
  Встроенный `vmalert` ограничен `ruleSelector` по лейблу
  `app.kubernetes.io/managed-by: sync-job` (этот лейбл ставят только `VMRule`,
  создаваемые sync-job). Свой PromQL-`VMRule`, созданный вручную, встроенный
  `vmalert` не подхватит. Варианты: проставлять лейбл
  `app.kubernetes.io/managed-by: sync-job` на кастомный `VMRule`; расширить
  `ruleSelector` (`matchExpressions` с `In` по нескольким значениям); оставить
  алерты по метрикам в Grafana UI.
