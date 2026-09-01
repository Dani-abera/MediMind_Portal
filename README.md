<div align="center">

# 🖥️ MediMind Portal

### Staff desktop application for the MediMind healthcare platform

**A cross‑platform Flutter desktop app for Doctors, Admins, and SuperAdmins — live queue control, appointment management, analytics, telemedicine, and reporting.**

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/Desktop-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

</div>

> Part of the **[MediMind platform](https://github.com/Dani-abera/MediMind-Backend-Api)** — see also the [Backend API](https://github.com/Dani-abera/MediMind-Backend-Api), [Patient App](https://github.com/Dani-abera/MediMind_Patient_App), and [ML Service](https://github.com/Dani-abera/MediMind-Disease-Prediction-ML).

---

## What it does

MediMind Portal is the **operational cockpit** used by hospital and clinic staff. While patients use the mobile app, staff run day‑to‑day operations from this desktop application: approving appointments, managing the live patient queue, configuring doctors and schedules, running video consultations, and reviewing analytics and reports.

Access is **role‑based**, with three tiers:

| Role | Can do |
|------|--------|
| **Doctor** | View their schedule & queue, run video consultations, issue prescriptions |
| **Admin** | Approve/reject appointments, control the live queue, manage doctors & schedules, view center analytics and reports |
| **SuperAdmin** | Everything above, plus register healthcare centers and operate the platform across tenants |

---

## Key Features

- **🎫 Live queue management** — real‑time queue dashboards over SignalR, call‑next, and no‑show handling
- **📅 Appointment operations** — approve, reject, and reschedule appointments; manage doctor schedules and availability
- **🏥 Center administration** — register healthcare centers, add doctors, configure working hours and booking rules
- **📊 Analytics dashboards** — interactive charts and calendars (Syncfusion, fl_chart) for daily and weekly trends
- **📄 Reporting** — export reports and documents to **PDF and Excel** (Syncfusion PDF/XlsIO)
- **🎥 Telemedicine** — in‑app video consultations and messaging via Agora RTC/RTM
- **💳 Payments** — Chapa payment integration for billing workflows
- **🗺️ Maps** — locate and display healthcare centers (flutter_map)
- **⌨️ Desktop‑native UX** — custom window management, global hotkeys, tray icon, and native notifications
- **🌍 Localization** — multi‑language support (easy_localization / intl)
- **🔐 Secure by design** — token stored in secure storage, obfuscated release builds, optional Sentry error tracking

---

## Tech Stack

| Area | Packages |
|------|----------|
| **State management** | flutter_bloc, bloc_concurrency, equatable |
| **Architecture** | get_it (DI), dartz (functional error handling) |
| **Networking** | dio, pretty_dio_logger, signalr_netcore, connectivity_plus |
| **Storage & security** | flutter_secure_storage, hive, shared_preferences |
| **Routing** | go_router, page_transition |
| **UI & data** | syncfusion_flutter_charts / calendar / pdf / xlsio, fl_chart, pluto_grid, data_table_2, shimmer, toastification |
| **Video & comms** | agora_rtc_engine, agora_rtm |
| **Payments** | chapasdk |
| **Desktop** | window_manager, hotkey_manager, tray_manager, bitsdojo_window, desktop_notifications, flutter_acrylic |
| **Forms & i18n** | reactive_forms, pinput, intl, easy_localization |
| **Monitoring** | sentry_flutter |

---

## Requirements

- Flutter **3.24+**, Dart **3.5+**
- A desktop platform: **Windows 10+**, **macOS 12+**, or **Ubuntu 20.04+**
- A running [MediMind Backend API](https://github.com/Dani-abera/MediMind-Backend-Api)

---

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

### Environment variables

| Key | Description | Default |
|-----|-------------|---------|
| `API_BASE_URL` | Backend base URL | `https://api.medimind.et` |
| `SENTRY_DSN` | Sentry DSN for error tracking | _(empty — Sentry disabled)_ |
| `ENV` | Environment name | `production` |

---

## Build (Release)

```bash
# Windows
flutter build windows --release --obfuscate --split-debug-info=build/symbols

# macOS
flutter build macos --release --obfuscate --split-debug-info=build/symbols

# Linux
flutter build linux --release --obfuscate --split-debug-info=build/symbols
```

---

## Testing

```bash
# Run all tests with coverage
flutter test --coverage

# View coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Coverage target: **75% line coverage**.

---

## Screenshots

> _Add a few screenshots of the dashboard, queue view, and analytics here — desktop admin apps are hard to picture from text alone, and screenshots make this repo instantly credible to reviewers._

---

## Documentation

- [Architecture](docs/architecture.md)
- [Keyboard shortcuts](docs/keyboard-shortcuts.md)
- [API integration](docs/api-integration.md)
- [Admin guide](docs/admin-guide.md) · [Super Admin guide](docs/super-admin-guide.md)

---

<div align="center">

Built by **[Daniel Abera Bogale](https://github.com/Dani-abera)** · Part of the MediMind project

</div>
