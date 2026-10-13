-- ============================================================
-- Кейс 24: Учёт проектных задач и загрузки команды
-- Схема данных v1.0
-- ============================================================
-- Источники:
--   - PDF "Кейсы ОПД" стр. 121-125 (Кейс 24) и стр. 150-151 (C24)
--   - Расширения команды помечены ⚠️
-- ============================================================

-- ============================================================
-- Сущность 1: Пользователи (совпадает с T1 кафедры)
-- PDF: users(user_id, role)
-- ============================================================
CREATE TABLE users (
  user_id   INT PRIMARY KEY,
  role      VARCHAR(30) NOT NULL
            CHECK (role IN ('teamlead', 'worker'))
  -- Обоснование: НФТ Кейса 24 (стр. 124) — 2 категории доступа:
  -- "исполнители — только свои задачи"
  -- "менеджеры — все"
  -- Это соответствует §1.5 (MVP ≤5 операций)
);

-- ============================================================
-- Сущность 2: Задачи (T1 + расширение created_by)
-- PDF: tasks(task_id, assignee, status, estimate_h, created_at, due_date)
-- ============================================================
CREATE TABLE tasks (
  task_id     INT PRIMARY KEY,
  assignee    INT NOT NULL,
  created_by  INT NOT NULL,                    -- ⚠️ расширение T1 (аудит)
  description TEXT NULL,
  status      VARCHAR(20) NOT NULL DEFAULT 'todo'
              CHECK (status IN ('todo', 'in_progress', 'review', 'done')),
  estimate_h  DECIMAL(6,2) NOT NULL CHECK (estimate_h >= 0),
  created_at  DATE NOT NULL,
  due_date    DATE NOT NULL CHECK (due_date >= created_at),
  -- ⚠️ closed_at НЕ хранится — derived field (см. business-rules.md)
  FOREIGN KEY (assignee)   REFERENCES users(user_id),
  FOREIGN KEY (created_by) REFERENCES users(user_id)
);

-- ============================================================
-- Сущность 3: Трудозатраты (совпадает с T1)
-- PDF: time_logs(task_id, user_id, date, hours)
-- ============================================================
CREATE TABLE time_logs (
  task_id  INT NOT NULL,
  user_id  INT NOT NULL,
  date     DATE NOT NULL,
  hours    DECIMAL(5,2) NOT NULL CHECK (hours >= 0),
  PRIMARY KEY (task_id, user_id, date),
  FOREIGN KEY (task_id) REFERENCES tasks(task_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- Сущность 4: История статусов (расширение для НФТ)
-- PDF стр. 124: "Трассируемость: хранение истории изменения статусов"
-- ============================================================
CREATE TABLE status_history (
  task_id     INT NOT NULL,
  changed_at  DATETIME NOT NULL,
  old_status  VARCHAR(20) NULL,
  new_status  VARCHAR(20) NOT NULL
              CHECK (new_status IN ('todo', 'in_progress', 'review', 'done')),
  changed_by  INT NOT NULL,
  PRIMARY KEY (task_id, changed_at),
  FOREIGN KEY (task_id)    REFERENCES tasks(task_id),
  FOREIGN KEY (changed_by) REFERENCES users(user_id)
);

-- ============================================================
-- Сущность 5: Отчёт по загрузке (VIEW, не таблица)
-- PDF golden: workload.csv(user_id, period, est_h, fact_h, over_alloc_flag)
-- ============================================================
CREATE VIEW workload_report AS
SELECT
  t.assignee                                        AS user_id,
  strftime('%Y-%m', tl.date)                        AS period,
  SUM(t.estimate_h)                                 AS est_h,
  COALESCE(SUM(tl.hours), 0)                        AS fact_h,
  CASE
    WHEN COALESCE(SUM(tl.hours), 0) > SUM(t.estimate_h)
    THEN 1 ELSE 0
  END                                               AS over_alloc_flag
FROM tasks t
LEFT JOIN time_logs tl ON tl.task_id = t.task_id
WHERE t.status IN ('in_progress', 'review', 'done')
GROUP BY t.assignee, strftime('%Y-%m', tl.date);

-- ============================================================
-- Итого: 4 таблицы + 1 VIEW = 5 сущностей
-- (требование PDF §7.2: ERD ≥5 сущностей)
-- ============================================================