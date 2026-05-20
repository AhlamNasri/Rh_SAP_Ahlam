# Endpoints API principaux

Tous les endpoints sauf login/register nécessitent `Authorization: Bearer <token>`.

## Auth

- `POST /api/auth/login`
- `POST /api/auth/register`
- `GET /api/auth/me`

Payload login:

```json
{
  "email": "employee@test.com",
  "password": "password"
}
```

## Employees

- `GET /api/employees`
- `GET /api/employees/{id}`
- `POST /api/employees`
- `PUT /api/employees/{id}`
- `DELETE /api/employees/{id}`
- `GET /api/employees/me`

## Leaves

- `GET /api/leaves`
- `GET /api/leaves/my`
- `POST /api/leaves`
- `PUT /api/leaves/{id}/approve`
- `PUT /api/leaves/{id}/reject`
- `DELETE /api/leaves/{id}`

Payload demande:

```json
{
  "type": "CONGE_ANNUEL",
  "startDate": "2026-06-01",
  "endDate": "2026-06-03",
  "reason": "Vacances"
}
```

## Attendance

- `GET /api/attendance`
- `GET /api/attendance/my`
- `POST /api/attendance/check-in`
- `POST /api/attendance/check-out`
- `GET /api/attendance/today`

## Dashboard

- `GET /api/dashboard/stats`
- `GET /api/dashboard/employees-by-department`
- `GET /api/dashboard/leaves-by-month`
- `GET /api/dashboard/attendance-summary`

## Payroll

- `GET /api/payroll`
- `GET /api/payroll/my`
- `GET /api/payroll/{id}`
- `POST /api/payroll`

## Recruitment

- `GET /api/jobs`
- `POST /api/jobs`
- `PUT /api/jobs/{id}`
- `DELETE /api/jobs/{id}`
- `GET /api/candidates`
- `POST /api/candidates`
- `PUT /api/candidates/{id}/status`

## Admin

- `GET /api/admin/users`
- `POST /api/admin/users`
- `PUT /api/admin/users/{id}`
- `PUT /api/admin/users/{id}/role`
- `PUT /api/admin/users/{id}/status`

## Performance

- `GET /api/performance`
- `GET /api/performance/my`
- `POST /api/performance`
- `PUT /api/performance/{id}`

## Training

- `GET /api/trainings`
- `POST /api/trainings`
- `PUT /api/trainings/{id}`
- `POST /api/trainings/{id}/enroll`
- `GET /api/trainings/my`

## Organization

- `GET /api/organization/tree`

## Reports

- `GET /api/reports/leaves`
- `GET /api/reports/attendance`
- `GET /api/reports/payroll`
- `GET /api/reports/trainings`
- `GET /api/reports/performance`
