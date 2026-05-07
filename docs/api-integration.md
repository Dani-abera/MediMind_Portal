# API Integration

Backend base URL: `https://api.medimind.et/api/v1`

## Authentication

All requests (except `/auth/*`) require `Authorization: Bearer <access_token>`.

The `AuthInterceptor` (Dio) automatically:
1. Attaches the access token from `flutter_secure_storage`.
2. On 401, attempts a silent token refresh via `POST /auth/refresh`.
3. On refresh failure, dispatches `AuthTokenExpired` to `AuthBloc` → navigates to login.

## Endpoints Reference

### Auth

| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/login` | Doctor / Admin login — returns tokens + user |
| POST | `/auth/login/super-admin` | SuperAdmin login (returns TOTP challenge) |
| POST | `/auth/totp/verify` | TOTP code verification |
| POST | `/auth/otp/request` | Doctor OTP request |
| POST | `/auth/otp/verify` | Doctor OTP verification |
| POST | `/auth/refresh` | Token refresh |
| POST | `/auth/logout` | Revoke refresh token |
| POST | `/auth/forgot-password` | Send reset email |
| POST | `/auth/reset-password` | Apply new password with token |

### System

| Method | Path | Description |
|--------|------|-------------|
| GET | `/system/version` | Returns `{ minSupported, latest, downloadUrl }` |

### Doctor Workspace

All paths prefixed with `/doctor`.

| Method | Path |
|--------|------|
| GET | `/doctor/dashboard` |
| GET/PATCH | `/doctor/profile` |
| GET | `/doctor/queue` |
| POST | `/doctor/queue/call-next` |
| GET/POST | `/doctor/appointments` |
| GET | `/doctor/patients` |
| GET | `/doctor/patients/:id` |
| GET/POST | `/doctor/prescriptions` |
| GET | `/doctor/prescriptions/templates` |
| GET/PUT | `/doctor/schedule` |
| GET/POST | `/doctor/consultations` |

### Admin Workspace

All paths prefixed with `/admin/{centerId}`.

| Method | Path |
|--------|------|
| GET | `/admin/{centerId}/dashboard` |
| GET | `/admin/{centerId}/queue` |
| POST | `/admin/{centerId}/queue/call-next` |
| GET/POST/PATCH | `/admin/{centerId}/appointments` |
| GET | `/admin/{centerId}/doctors` |
| POST | `/admin/{centerId}/doctors/invite` |
| GET | `/admin/{centerId}/patients` |
| GET | `/admin/{centerId}/payments` |
| GET | `/admin/{centerId}/analytics/dashboard` |
| GET | `/admin/{centerId}/analytics/revenue` |
| GET | `/admin/{centerId}/analytics/per-doctor` |
| GET | `/admin/{centerId}/audit-log` |
| GET/PUT | `/admin/{centerId}/settings/general` |
| GET/PUT | `/admin/{centerId}/settings/branding` |
| GET/PUT | `/admin/{centerId}/settings/hours` |
| GET/PUT | `/admin/{centerId}/settings/booking-rules` |
| POST | `/admin/{centerId}/settings/branding/upload` |

### SuperAdmin Workspace

All paths prefixed with `/super-admin`.

| Method | Path |
|--------|------|
| GET | `/super-admin/dashboard` |
| GET | `/super-admin/centers` |
| GET | `/super-admin/centers/:id` |
| POST | `/super-admin/centers/:id/approve` |
| POST | `/super-admin/centers/:id/reject` |
| POST | `/super-admin/centers/:id/suspend` |
| POST | `/super-admin/centers/:id/reactivate` |
| GET | `/super-admin/doctors` |
| POST | `/super-admin/doctors/:id/verify-license` |
| POST | `/super-admin/doctors/:id/suspend` |
| GET | `/super-admin/users` |
| POST | `/super-admin/users/:id/suspend` |
| POST | `/super-admin/users/:id/reactivate` |
| POST | `/super-admin/users/:id/force-logout` |
| DELETE | `/super-admin/users/:id` |
| GET | `/super-admin/subscriptions` |
| POST | `/super-admin/subscriptions/:id/change-plan` |
| GET | `/super-admin/analytics/dashboard` |
| GET | `/super-admin/analytics/revenue` |
| GET | `/super-admin/analytics/growth` |
| GET | `/super-admin/audit-log` |
| GET | `/super-admin/audit-log/export` |
| GET/PUT | `/super-admin/settings` |

## Pagination

All list endpoints accept `?page=1&limit=20`. Response envelope:

```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 342,
    "totalPages": 18
  }
}
```

## Error Format

```json
{
  "statusCode": 422,
  "message": "Validation failed",
  "errors": {
    "email": ["must be a valid email"]
  }
}
```

HTTP 401 → token expired → auto-refresh.  
HTTP 403 → insufficient permissions → show error toast.  
HTTP 422 → validation errors → display inline on form fields.  
HTTP 500 → server error → show generic error dialog, report to Sentry.
