## 4.5. Метрики успеха

| Метрика | Формула | Целевое значение | Источник |
|---|---|---|---|
| **`on_time_rate`** | count(done ∧ closed_at ≤ due_date) / count(done) | ≥ 80% | `sla_tasks.csv` |
| **`over_alloc_rate`** | count(users с fact_h > est_h) / count(users) | ≤ 15% | `workload.csv` |
| **Средняя загрузка** | Σ fact_h / count(users) | 140–170 ч/мес | `workload.csv` |
| **Точность экспорта** | \|workload_team - workload_golden\| / workload_golden | ≤ 1% | Сверка с golden |
| **Время формирования отчёта** | Время генерации `workload.csv` на T1 | ≤ 3 сек | Логи 1С |
| **Доля валидных данных** | count(успешных строк) / count(всех строк) при импорте | ≥ 95% | Логи импорта |
| **Покрытие acceptance** | count(выполненных AC) / count(всех AC) | 100% | Acceptance-чеклист |