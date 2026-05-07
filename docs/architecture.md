# Architecture

## Overview

MediMind Portal follows **Clean Architecture** with feature-based folder organization. Each role (Doctor, Admin, SuperAdmin) has an isolated workspace — the app loads only the active user's workspace at runtime.

```
lib/
├── core/               # Shared infrastructure (theme, routing, DI, widgets)
│   ├── di/             # GetIt service locator
│   ├── network/        # Dio client, interceptors, UserContext, RealtimeService
│   ├── routing/        # GoRouter + route guards
│   ├── services/       # Analytics, connectivity, inactivity, app update
│   ├── storage/        # Hive + SecureStorage wrappers
│   ├── theme/          # AppTheme, AppColors, ThemeCubit
│   └── widgets/        # Shell, charts, tables, command palette, etc.
├── features/
│   ├── auth/           # Login, OTP, 2FA, TOTP, forgot/reset password
│   ├── doctor/         # Doctor workspace
│   ├── admin/          # Admin workspace
│   └── super_admin/    # SuperAdmin workspace
└── shared/
    └── blocs/          # Cross-feature blocs (NotificationBloc)
```

## Layer Boundaries

Each feature follows **domain → data → presentation**:

| Layer | Responsibilities |
|-------|-----------------|
| `domain/entities/` | Pure Dart, no framework deps |
| `domain/repositories/` | Abstract interfaces only |
| `domain/usecases/` | Single-responsibility business logic |
| `data/datasources/` | HTTP (Dio) or local (Hive/SecureStorage) |
| `data/repositories/` | Implements domain interface, maps models → entities |
| `presentation/bloc/` | BLoC/Cubit — events, states, business-logic coordination |
| `presentation/pages/` | StatelessWidget pages, read from BLoC |
| `presentation/widgets/` | Reusable page-level widgets |

## State Management

- **BLoC** for all async operations (API calls, form submission)
- **Cubit** for simple synchronous state (theme, sidebar collapse, connectivity)
- `BlocSelector` for fine-grained widget subscriptions — avoids rebuilding the whole tree

## Routing

GoRouter with `StatefulShellRoute.indexedStack` per workspace. Route guards in `_redirect` check `UserContext.isAuthenticated` and `UserContext.userType` on every navigation event.

Each workspace shell is a `StatefulWidget` with its own `ShellBloc` (sidebar state, breadcrumbs, connection status).

## Dependency Injection

GetIt singleton. Injection files per feature (`auth_injection.dart`, `doctor_injection.dart`, etc.) called from `initCoreDependencies()`.

## Multi-Tenancy

- **Admin** operations are scoped: every admin use case takes `String centerId` as a mandatory positional parameter (fetched from `UserContext.centerId`).
- **SuperAdmin** operations are platform-wide: no centerId scoping.

## Security

- Tokens stored in `flutter_secure_storage`.
- Auto-logout via `InactivityService` (default 30 min, configurable).
- Sensitive fields wrapped in `NoCopyText` to block clipboard access.
- Release builds obfuscated: `--obfuscate --split-debug-info=build/symbols`.

## Real-Time

`RealtimeService` wraps `signalr_netcore`. `ShellBloc` subscribes on construction and maps connection events to `AppConnectionStatus` state.

## Error Handling

- `runZonedGuarded` in `main.dart` catches all unhandled async errors → Sentry.
- `FlutterError.onError` catches widget tree errors → Sentry.
- Every BLoC `on<Event>` wraps repository calls with `dartz.Either` — failures map to typed `XxxFailure` states that the UI renders as error cards with retry buttons.
