CREATE TABLE users (
  user_id INT PRIMARY KEY,
  role VARCHAR(30) NOT NULL
);

CREATE TABLE tasks (
  task_id INT PRIMARY KEY,
  assignee INT NOT NULL REFERENCES users(user_id),
  created_by INT NOT NULL REFERENCES users(user_id),
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'todo',
  estimate_h DECIMAL(6,2) NOT NULL,
  created_at DATE NOT NULL,
  due_date DATE NOT NULL
);

CREATE TABLE time_logs (
  task_id INT PRIMARY KEY REFERENCES tasks(task_id),
  user_id INT PRIMARY KEY REFERENCES users(user_id),
  date DATE PRIMARY KEY,
  hours DECIMAL(5,2) NOT NULL
);

CREATE TABLE status_history (
  task_id INT PRIMARY KEY REFERENCES tasks(task_id),
  changed_at DATETIME PRIMARY KEY,
  old_status VARCHAR(20),
  new_status VARCHAR(20) NOT NULL,
  changed_by INT NOT NULL REFERENCES users(user_id)
);