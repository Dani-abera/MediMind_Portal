# MediMind Portal v1.0.0 — Release Readiness Report

Generated: 2026-05-06

---

## 1. Functional Requirements Status

| FR | Feature | Portal Screen | Role | Status |
|----|---------|---------------|------|--------|
| FR-001 | Doctor login (OTP via badge) | LoginPage — Doctor tab | Doctor | ✅ Complete |
| FR-002 | Admin login (email/password + optional 2FA) | LoginPage — Admin tab | Admin | ✅ Complete |
| FR-003 | SuperAdmin login (TOTP mandatory) | LoginPage — SuperAdmin tab | SuperAdmin | ✅ Complete |
| FR-004 | Forgot / Reset password | ForgotPasswordPage, ResetPasswordPage | All | ✅ Complete |
| FR-005 | Account lockout after 5 failures | LoginPage (AccountLockoutCubit) | All | ✅ Complete |
| FR-006 | Doctor dashboard (KPIs, today schedule) | DoctorDashboardPage | Doctor | ✅ Complete |
| FR-007 | Live queue view + call next | QueuePage | Doctor | ✅ Complete |
| FR-008 | Appointment calendar | AppointmentsCalendarPage | Doctor | ✅ Complete |
| FR-009 | Appointment list | AppointmentsListPage | Doctor | ✅ Complete |
| FR-010 | Patient list & detail | PatientsListPage, PatientDetailPage | Doctor | ✅ Complete |
| FR-011 | Write prescription | CreatePrescriptionPage | Doctor | ✅ Complete |
| FR-012 | Prescription templates | PrescriptionTemplatesPage | Doctor | ✅ Complete |
| FR-013 | Schedule management | SchedulePage | Doctor | ✅ Complete |
| FR-014 | Video consultation | VideoCallPage (WebRTC) | Doctor | ✅ Complete |
| FR-015 | Admin dashboard (KPIs, charts) | AdminDashboardPage | Admin | ✅ Complete |
| FR-016 | Admin queue management + walk-in | LiveQueuePage | Admin | ✅ Complete |
| FR-017 | Pending appointments (approve/reject/bulk) | PendingAppointmentsPage | Admin | ✅ Complete |
| FR-018 | Appointment calendar (admin view) | AdminCalendarPage | Admin | ✅ Complete |
| FR-019 | All appointments table | AllAppointmentsPage | Admin | ✅ Complete |
| FR-020 | Doctors roster | DoctorsRosterPage | Admin | ✅ Complete |
| FR-021 | Patient directory + detail | PatientDirectoryPage, AdminPatientDetailPage | Admin | ✅ Complete |
| FR-022 | Payments ledger | PaymentsLedgerPage | Admin | ✅ Complete |
| FR-023 | Analytics (dashboard/revenue/per-doctor/export) | AnalyticsDashboardPage, RevenuePage, PerDoctorPage, ExportWizardPage | Admin | ✅ Complete |
| FR-024 | Admin audit log | AuditLogPage | Admin | ✅ Complete |
| FR-025 | Center settings (general/branding/hours/booking) | CenterGeneralPage, CenterBrandingPage, CenterHoursPage, BookingRulesPage | Admin | ✅ Complete |
| FR-026 | SuperAdmin dashboard + pending alerts | SuperAdminDashboardPage | SuperAdmin | ✅ Complete |
| FR-027 | Centers management (approve/reject/suspend/reactivate) | CentersPage, CenterDetailPage | SuperAdmin | ✅ Complete |
| FR-028 | Platform doctors (verify license, suspend) | PlatformDoctorsPage | SuperAdmin | ✅ Complete |
| FR-029 | Platform users (suspend/reactivate/force-logout/delete) | PlatformUsersPage | SuperAdmin | ✅ Complete |
| FR-030 | Platform subscriptions (change plan) | PlatformSubscriptionsPage | SuperAdmin | ✅ Complete |
| FR-031 | Platform analytics (dashboard/revenue/growth) | PlatformAnalyticsPage | SuperAdmin | ✅ Complete |
| FR-032 | Global audit log (cross-center) | GlobalAuditLogPage | SuperAdmin | ✅ Complete |
| FR-033 | Platform settings (pricing/limits/feature flags/maintenance) | PlatformSettingsPage | SuperAdmin | ✅ Complete |

---

## 2. Non-Functional Requirements Compliance

| NFR | Requirement | Status | Notes |
|-----|-------------|--------|-------|
| NFR-001 | Desktop: Windows/macOS/Linux | ✅ | flutter build for all 3 platforms |
| NFR-002 | Secure token storage | ✅ | flutter_secure_storage |
| NFR-003 | SSL/TLS in transit | ✅ | Dio enforces HTTPS; SSL pinning in prod config |
| NFR-004 | Auto-logout on inactivity (30 min) | ✅ | InactivityService wired into WorkspaceShell |
| NFR-005 | Build obfuscation | ✅ | --obfuscate --split-debug-info in CI |
| NFR-006 | Error tracking (Sentry) | ✅ | runZonedGuarded + FlutterError.onError |
| NFR-007 | Analytics / event logging | ✅ | AnalyticsService (Sentry breadcrumbs) |
| NFR-008 | Offline detection + banner | ✅ | ConnectivityCubit + OfflineBanner |
| NFR-009 | App version check (min / latest) | ✅ | AppUpdateService + ForceUpdateScreen |
| NFR-010 | Sensitive field copy prevention | ✅ | NoCopyText widget |
| NFR-011 | Keyboard navigation | ✅ | Tab order, GlobalShortcutsWidget, focus management |
| NFR-012 | i18n: English + Amharic | ✅ | easy_localization, en/am JSON files |
| NFR-013 | Test coverage ≥ 75% | 🔶 Partial | 120 tests pass; full coverage report requires running flutter test --coverage + genhtml |
| NFR-014 | Multi-tenancy isolation | ✅ | Admin use cases scoped to centerId; tenant boundary test |
| NFR-015 | CI/CD pipeline | ✅ | .github/workflows/portal-ci.yaml |
| NFR-016 | Command palette | ✅ | Role-specific command palette (Ctrl+K) |
| NFR-017 | Dark / light theme | ✅ | ThemeCubit, persisted via SharedPreferences |
| NFR-018 | Real-time connection status | ✅ | RealtimeService + ShellBloc |

---

## 3. Per-Platform Installer Status

| Platform | Build | Signing | Installer | Status |
|----------|-------|---------|-----------|--------|
| Windows | ✅ flutter build windows | 🔶 EV cert (manual) | 🔶 Inno Setup (CI step provided) | Pending cert procurement |
| macOS | ✅ flutter build macos | 🔶 Apple Developer ID (manual) | 🔶 DMG (CI step provided) | Pending Apple cert |
| Linux | ✅ flutter build linux | N/A | 🔶 AppImage (CI step provided) | CI step ready |

---

## 4. Code Signing Status

| Platform | Signing Method | Status |
|----------|---------------|--------|
| Windows | EV Code Signing Certificate + codesign | 🔶 Awaiting certificate |
| macOS | Apple Developer ID + notarize via altool | 🔶 Awaiting Apple Developer account |
| Linux | GPG signature on AppImage (optional) | Not required for v1.0 |

---

## 5. Known Issues

| Priority | Issue | Area |
|----------|-------|------|
| P2 | Doctor/Admin Profile and Notifications pages are placeholders | Doctor, Admin |
| P2 | Admin Prescriptions page is a placeholder | Admin |
| P3 | No push notification integration (desktop_notifications not yet driven by backend events) | All |
| P3 | Video call (WebRTC) requires signaling server configuration in .env | Doctor |
| P3 | Amharic translations: string file exists but only partial strings translated | All |

---

## 6. Final Verification Checklist

- [x] `flutter analyze` — 0 issues
- [x] `flutter test` — 120/120 passing
- [ ] `flutter build windows --release --obfuscate` — run before release
- [ ] `flutter build macos --release --obfuscate` — run before release
- [ ] `flutter build linux --release --obfuscate` — run before release
- [ ] Smoke test all 3 workspaces on each platform
- [ ] Memory profile: no leaks after 30-min cycling
- [ ] Performance: 60 FPS on table scroll, chart render
- [ ] Accessibility: keyboard navigation through every page
- [ ] Security audit: `grep -r "password\|secret\|api_key" lib/` returns nothing hardcoded
- [ ] Sentry DSN set in production .env
- [ ] Code signing complete for Windows and macOS

---

## 7. Release Notes — v1.0.0

### Doctor Workspace
- OTP login with 2-step badge verification
- Dashboard with today's appointments, queue status, earnings
- Live patient queue with call-next
- Full appointment calendar (Syncfusion)
- Patient records with prescription history
- Prescription writing with template library
- Schedule management
- WebRTC video consultations

### Admin Workspace
- Email/password login with optional 2FA
- Dashboard with center-level KPIs and charts
- Live queue management (call next, walk-in)
- Appointment approval with bulk actions
- Doctor roster management
- Patient directory
- Payments ledger
- Analytics suite (revenue, per-doctor, export wizard)
- Full audit log
- Center settings (general, branding, hours, booking rules)

### SuperAdmin Workspace
- Mandatory TOTP login
- Platform-wide dashboard with growth charts
- Center lifecycle management (approve, reject, suspend, reactivate)
- Center detail (subscription, doctors, activity, audit)
- Platform-wide doctor verification and suspension
- User management (suspend, force-logout, delete)
- Subscription management with plan changes
- Platform analytics (dashboard, revenue, growth)
- Cross-center audit log
- Platform settings (pricing, limits, feature flags, maintenance mode)

### Infrastructure
- Clean Architecture with feature-based folder organization
- BLoC state management throughout
- runZonedGuarded global error handling → Sentry
- Offline detection banner
- Auto-logout after inactivity (30 min)
- App version check with forced-update screen
- Keyboard shortcuts (Ctrl+K command palette, Ctrl+/ help, etc.)
- i18n: English + Amharic
- CI/CD: GitHub Actions (analyze, test, build all platforms, GitHub Release on tag)
