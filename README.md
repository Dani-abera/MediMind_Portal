# MediMind Portal

Staff-only desktop application for MediMind healthcare platform — Doctors, Admins, and SuperAdmins.

## Requirements

- Flutter 3.24+
- Dart 3.5+
- Desktop platform: Windows 10+, macOS 12+, Ubuntu 20.04+

## Setup

```bash
# 1. Clone and install dependencies
flutter pub get

# 2. Configure environment
cp .env.example .env
# Edit .env and set API_BASE_URL, SENTRY_DSN, etc.

# 3. Run in development
flutter run -d windows   # or macos / linux
```

## Environment Variables

| Key | Description | Default |
|-----|-------------|---------|
| `API_BASE_URL` | Backend base URL | `https://api.medimind.et` |
| `SENTRY_DSN` | Sentry DSN for error tracking | (empty — Sentry disabled) |
| `ENV` | Environment name | `production` |

## Build (Release)

```bash
# Windows
flutter build windows --release --obfuscate --split-debug-info=build/symbols

# macOS
flutter build macos --release --obfuscate --split-debug-info=build/symbols

# Linux
flutter build linux --release --obfuscate --split-debug-info=build/symbols
```

## Testing

```bash
# Run all tests with coverage
flutter test --coverage

# View coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Coverage target: **75% line coverage**.

## Architecture

See [docs/architecture.md](docs/architecture.md).

## Keyboard Shortcuts

See [docs/keyboard-shortcuts.md](docs/keyboard-shortcuts.md).

## API Contract

See [docs/api-integration.md](docs/api-integration.md).

## Admin Guides

- [Admin Guide](docs/admin-guide.md) — for end-user healthcare administrators
- [Super Admin Guide](docs/super-admin-guide.md) — for platform operators
