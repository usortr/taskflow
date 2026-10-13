# API-контракты Кейса 24
## Мок-REST для UI-прототипа

Base URL: `http://localhost:3000/api`

---

## GET /tasks
Получить список задач (с фильтрами).

**Request:**
```
GET /api/tasks?status=in_progress&assignee=2
```

**Response (200 OK):**
```json
{
  "tasks": [
    {
      "task_id": 1,
      "assignee": {"user_id": 2, "role": "worker"},
      "status": "in_progress",
      "estimate_h": 8.00,
      "fact_h": 3.50,
      "created_at": "2026-10-01",
      "due_date": "2026-10-15"
    }
  ]
}
```

---

## POST /time-logs
Записать трудозатраты.

**Request:**
```json
{
  "task_id": 1,
  "user_id": 2,
  "date": "2026-10-05",
  "hours": 3.00
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "log_id": "1-2-2026-10-05"
}
```

**Response (400 Bad Request):**
```json
{
  "error": "user_id 2 is not assignee of task 1"
}
```

---

## PATCH /tasks/:id/status
Изменить статус задачи.

**Request:**
```json
{
  "status": "review",
  "changed_by": 2
}
```

**Response (200 OK):**
```json
{
  "task_id": 1,
  "old_status": "in_progress",
  "new_status": "review",
  "changed_at": "2026-10-05T14:30:00"
}
```

**Response (400 Bad Request):**
```json
{
  "error": "invalid status transition: todo -> review"
}
```

---

## GET /workload
Получить отчёт по загрузке.

**Request:**
```
GET /api/workload?period=2026-10
```

**Response (200 OK):**
```json
{
  "workload": [
    {
      "user_id": 1,
      "period": "2026-10",
      "est_h": 40.00,
      "fact_h": 45.00,
      "over_alloc_flag": 1
    },
    {
      "user_id": 2,
      "period": "2026-10",
      "est_h": 32.00,
      "fact_h": 30.00,
      "over_alloc_flag": 0
    }
  ]
}
```

---

## GET /sla
Получить SLA по задачам.

**Request:**
```
GET /api/sla?period=2026-10
```

**Response (200 OK):**
```json
{
  "sla": [
    {"task_id": 1, "on_time_flag": 1},
    {"task_id": 2, "on_time_flag": 0},
    {"task_id": 3, "on_time_flag": 1}
  ],
  "on_time_rate": 0.67
}
```

---

## Коды ошибок
- `200 OK` — успех
- `201 Created` — ресурс создан
- `400 Bad Request` — ошибка валидации (описание в `error`)
- `404 Not Found` — ресурс не найден
- `500 Internal Server Error` — внутренняя ошибка