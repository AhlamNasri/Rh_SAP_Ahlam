-- PostgreSQL compatible schema for SAP HCM HR demo.
-- The Spring Boot demo also supports automatic schema creation through JPA.

CREATE TABLE IF NOT EXISTS roles (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS departments (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL UNIQUE,
  description VARCHAR(400)
);

CREATE TABLE IF NOT EXISTS employees (
  id BIGSERIAL PRIMARY KEY,
  employee_number VARCHAR(40) NOT NULL UNIQUE,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  job_title VARCHAR(120) NOT NULL,
  department_id BIGINT REFERENCES departments(id),
  email VARCHAR(120) NOT NULL UNIQUE,
  phone VARCHAR(30),
  address VARCHAR(255),
  hire_date DATE,
  contract_type VARCHAR(30),
  manager_id BIGINT REFERENCES employees(id),
  active BOOLEAN DEFAULT TRUE,
  avatar_url VARCHAR(400),
  base_salary NUMERIC(12,2),
  annual_leave_balance INT DEFAULT 24
);

CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(120) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  employee_id BIGINT REFERENCES employees(id),
  enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_roles (
  user_id BIGINT REFERENCES users(id),
  role_id BIGINT REFERENCES roles(id),
  PRIMARY KEY(user_id, role_id)
);

CREATE TABLE IF NOT EXISTS leave_requests (
  id BIGSERIAL PRIMARY KEY,
  employee_id BIGINT NOT NULL REFERENCES employees(id),
  type VARCHAR(50) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  days INT NOT NULL,
  reason VARCHAR(800),
  status VARCHAR(50) NOT NULL,
  approved_by_id BIGINT REFERENCES employees(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  decision_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS attendance (
  id BIGSERIAL PRIMARY KEY,
  employee_id BIGINT NOT NULL REFERENCES employees(id),
  date DATE NOT NULL,
  check_in_time TIME,
  check_out_time TIME,
  total_hours NUMERIC(5,2),
  status VARCHAR(50),
  UNIQUE(employee_id, date)
);

CREATE TABLE IF NOT EXISTS payroll (
  id BIGSERIAL PRIMARY KEY,
  employee_id BIGINT NOT NULL REFERENCES employees(id),
  month VARCHAR(7) NOT NULL,
  base_salary NUMERIC(12,2),
  bonuses NUMERIC(12,2),
  overtime NUMERIC(12,2),
  deductions NUMERIC(12,2),
  charges NUMERIC(12,2),
  gross_salary NUMERIC(12,2),
  net_salary NUMERIC(12,2),
  payment_date DATE,
  status VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS job_offers (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(160) NOT NULL,
  department_id BIGINT REFERENCES departments(id),
  contract_type VARCHAR(30),
  publication_date DATE,
  status VARCHAR(50),
  description VARCHAR(1200)
);

CREATE TABLE IF NOT EXISTS candidates (
  id BIGSERIAL PRIMARY KEY,
  job_offer_id BIGINT REFERENCES job_offers(id),
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(120) NOT NULL,
  cv_url VARCHAR(400),
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS performance_reviews (
  id BIGSERIAL PRIMARY KEY,
  employee_id BIGINT NOT NULL REFERENCES employees(id),
  manager_id BIGINT REFERENCES employees(id),
  period VARCHAR(40) NOT NULL,
  objective1 VARCHAR(500),
  objective2 VARCHAR(500),
  objective3 VARCHAR(500),
  score INT,
  comment VARCHAR(1200),
  status VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS trainings (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(160) NOT NULL,
  description VARCHAR(1200),
  duration_hours INT,
  trainer VARCHAR(120),
  start_date DATE,
  end_date DATE,
  status VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS training_enrollments (
  id BIGSERIAL PRIMARY KEY,
  training_id BIGINT NOT NULL REFERENCES trainings(id),
  employee_id BIGINT NOT NULL REFERENCES employees(id),
  progress_percent INT DEFAULT 0,
  UNIQUE(training_id, employee_id)
);

CREATE TABLE IF NOT EXISTS reports (
  id BIGSERIAL PRIMARY KEY,
  type VARCHAR(50),
  title VARCHAR(160) NOT NULL,
  payload_summary VARCHAR(2000),
  generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
