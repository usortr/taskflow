# Расширения T1 (от команды)
- tasks.created_by: добавлено для аудита (кто поставил задачу)
- status_history: добавлено для НФТ «Трассируемость» (PDF стр. 124)

# Упрощения MVP
- users.role: 2 роли (teamlead, worker) вместо 4 из PDF
  Обоснование: §1.5 MVP ≤5 операций

# Вычисляемые поля (derived)
- tasks.closed_at:
    formula: "MAX(time_logs.date) WHERE task_id = X AND status = 'done'"
    note: "Не хранится, вычисляется на лету"

# Дополнительные валидации
- time_logs.user_id == tasks.assignee
  reason: "PDF стр. 123: в задаче один исполнитель"
  implementation: "Проверка в обработке импорта 1С"