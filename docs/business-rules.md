# Бизнес-правила Кейса 24
## Источник: PDF стр. 122-124 (Кейс 24)

### BR-01. Статусный поток задач
Задача проходит строго последовательно:
`todo → in_progress → review → done`
Пропуск статусов запрещён. Возврат на предыдущий этап — только через тимлида.

### BR-02. Закрытие задачи
Задача считается закрытой, когда `status = 'done'`.
`closed_at` вычисляется как `MAX(time_logs.date)` по этой задаче.

### BR-03. Контроль сроков (SLA)
Задача выполнена «в срок», если:
- `status = 'done'`
- `closed_at <= due_date`

KPI `on_time_rate` = count(в срок) / count(done)

### BR-04. Учёт загрузки
Для каждого пользователя за период (YYYY-MM):
- `est_h` = SUM(estimate_h) по всем задачам, где он assignee
- `fact_h` = SUM(hours) из time_logs по его задачам

### BR-05. Флаг перегрузки
`over_alloc_flag = 1`, если `fact_h > est_h`
Иначе `over_alloc_flag = 0`

### BR-06. Один исполнитель на задачу
В одной задаче может участвовать только один исполнитель (assignee).
`time_logs.user_id` обязан совпадать с `tasks.assignee`.

### BR-07. Неотрицательные значения
- `estimate_h >= 0`
- `hours >= 0`
Отрицательные значения отклоняются при импорте.

### BR-08. Корректность дат
- `due_date >= created_at`
- `time_logs.date >= tasks.created_at` (логически)

### BR-09. Ссылочная целостность
- `tasks.assignee` → существует в `users`
- `tasks.created_by` → существует в `users`
- `time_logs.task_id` → существует в `tasks`
- `time_logs.user_id` → существует в `users`

### BR-10. Роли и доступы
- **worker**: видит только свои задачи, может менять статус и писать часы
- **teamlead**: видит все задачи, может импортировать/экспортировать CSV,
  назначать задачи, просматривать дашборд загрузки

### BR-11. Импорт CSV идемпотентен
Повторная загрузка одного и того же CSV не создаёт дубликатов.
Ключи идемпотентности:
- `users.user_id`
- `tasks.task_id`
- `(time_logs.task_id, time_logs.user_id, time_logs.date)`

### BR-12. Валидации при импорте (минимум 5 — PDF стр. 123)
1. `estimate_h >= 0`, `hours >= 0`
2. `assignee` существует в `users`
3. Статусный поток: `todo → in_progress → review → done`
4. `time_logs.task_id` существует в `tasks`
5. `due_date >= created_at`

### BR-13. Трассируемость (НФТ, PDF стр. 124)
При каждом изменении `tasks.status` пишется запись в `status_history`:
- `task_id`
- `changed_at` (текущая дата-время)
- `old_status`, `new_status`
- `changed_by` (user_id, кто изменил)

### BR-14. Формат периода
Период в `workload_report` — формат `YYYY-MM` (например, `2026-10`).
Совпадает с `golden/workload.csv` от кафедры.

### BR-15. Экспорт CSV
- `workload.csv`: `user_id, period, est_h, fact_h, over_alloc_flag`
- `sla_tasks.csv`: `task_id, on_time_flag` (или агрегат `on_time_rate`)
Формат: UTF-8, разделитель `,`, кавычки `"`, decimal с точкой.