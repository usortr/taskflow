# Формат CSV Кейса 24

## Общие правила (PDF Приложение C, стр. 141)
- Кодировка: UTF-8
- Разделитель: `,` (запятая)
- Кавычки: `"` (двойные)
- Перевод строки: `\n`
- Даты: `YYYY-MM-DD`
- Дата-время: `YYYY-MM-DDTHH:MM:SS`
- Числа: decimal с точкой (например, `8.50`)
- Null: пустая строка

---

## Входные файлы (T1 от кафедры)

### 1. `users.csv`
| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| user_id | int | да | PK |
| role | string | да | `teamlead` или `worker` |

**Пример:**
```csv
user_id,role
1,teamlead
2,worker
3,worker
```

**Объём T1 (PDF стр. 151):** 10–20 строк

---

### 2. `tasks.csv`
| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| task_id | int | да | PK |
| assignee | int | да | FK → users.user_id |
| status | string | да | `todo`, `in_progress`, `review`, `done` |
| estimate_h | decimal | да | >= 0 |
| created_at | date | да | YYYY-MM-DD |
| due_date | date | да | >= created_at |

**Пример:**
```csv
task_id,assignee,status,estimate_h,created_at,due_date
1,2,todo,8.00,2026-10-01,2026-10-15
2,3,in_progress,12.50,2026-10-02,2026-10-20
3,2,done,6.00,2026-10-01,2026-10-10
```

**Объём T1:** 150–250 строк

---

### 3. `time_logs.csv`
| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| task_id | int | да | FK → tasks.task_id |
| user_id | int | да | FK → users.user_id (== tasks.assignee) |
| date | date | да | YYYY-MM-DD |
| hours | decimal | да | >= 0 |

**Пример:**
```csv
task_id,user_id,date,hours
1,2,2026-10-05,3.00
1,2,2026-10-06,2.50
2,3,2026-10-03,4.00
```

**Объём T1:** 600–1000 строк

---

## Выходные файлы (Golden от кафедры)

### 4. `workload.csv` (экспорт из 1С)
| Поле | Тип | Описание |
|------|-----|----------|
| user_id | int | ID пользователя |
| period | string | YYYY-MM |
| est_h | decimal | Сумма оценок |
| fact_h | decimal | Сумма фактических часов |
| over_alloc_flag | int | 1 если fact_h > est_h, иначе 0 |

**Пример:**
```csv
user_id,period,est_h,fact_h,over_alloc_flag
1,2026-10,40.00,45.00,1
2,2026-10,32.00,30.00,0
3,2026-10,24.00,28.50,1
```

**Критерий приёмки:** совпадение с `golden/workload.csv` ±1% на округления.

---

### 5. `sla_tasks.csv` (экспорт из 1С)
| Поле | Тип | Описание |
|------|-----|----------|
| task_id | int | ID задачи |
| on_time_flag | int | 1 если closed_at <= due_date, иначе 0 |

**Пример:**
```csv
task_id,on_time_flag
1,1
2,0
3,1
```

**Критерий приёмки:** совпадение с `golden/sla_tasks.csv`.

---

## Негативные примеры (`/invalid/`)

### `users_invalid_role.csv`
```csv
user_id,role
99,manager
```
**Ожидаемая ошибка:** `role must be in ('teamlead', 'worker')`

### `tasks_negative_estimate.csv`
```csv
task_id,assignee,status,estimate_h,created_at,due_date
99,2,todo,-5.00,2026-10-01,2026-10-15
```
**Ожидаемая ошибка:** `estimate_h must be >= 0`

### `time_logs_unknown_user.csv`
```csv
task_id,user_id,date,hours
1,999,2026-10-05,3.00
```
**Ожидаемая ошибка:** `user_id 999 not found in users`