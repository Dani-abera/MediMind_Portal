import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/user_context.dart';
import '../widgets/shell/placeholder_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/doctor/doctor_workspace.dart';
import '../../features/doctor/presentation/pages/doctor_dashboard_page.dart';
import '../../features/doctor/presentation/pages/queue_page.dart';
import '../../features/doctor/presentation/pages/appointments_list_page.dart';
import '../../features/doctor/presentation/pages/appointments_calendar_page.dart';
import '../../features/doctor/presentation/pages/patients_list_page.dart';
import '../../features/doctor/presentation/pages/patient_detail_page.dart';
import '../../features/doctor/presentation/pages/consultations_page.dart';
import '../../features/doctor/presentation/pages/video_call_page.dart';
import '../../features/doctor/presentation/pages/prescriptions_list_page.dart';
import '../../features/doctor/presentation/pages/create_prescription_page.dart';
import '../../features/doctor/presentation/pages/prescription_templates_page.dart';
import '../../features/doctor/presentation/pages/schedule_page.dart';
import '../../features/doctor/presentation/pages/doctor_profile_page.dart';
import '../../features/admin/admin_workspace.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/super_admin/super_admin_workspace.dart';
import '../../features/super_admin/presentation/pages/super_admin_dashboard_page.dart';
import 'route_names.dart';

class AppRouter {
  final UserContext _ctx;

  AppRouter(this._ctx);

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: _redirect,
    routes: [
      // ── Public ─────────────────────────────────────────────────────────
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: RouteNames.forgotPassword, builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, state) => ResetPasswordPage(token: state.uri.queryParameters['token']),
      ),

      // ── Video call (full-screen, no shell) ──────────────────────────────
      GoRoute(
        path: '/doctor/video-call/:id',
        builder: (_, state) =>
            VideoCallPage(consultationId: state.pathParameters['id']!),
      ),

      // ── Doctor workspace ────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => DoctorWorkspace(navigationShell: shell),
        branches: [
          // Dashboard
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorDashboard,
              builder: (_, __) => const DoctorDashboardPage(),
            ),
          ]),
          // Queue
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorQueue,
              builder: (_, __) => const QueuePage(),
            ),
          ]),
          // Appointments
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorAppointments,
              redirect: (_, __) => RouteNames.doctorAppointmentsCalendar,
            ),
            GoRoute(
              path: RouteNames.doctorAppointmentsCalendar,
              builder: (_, __) => const AppointmentsCalendarPage(),
            ),
            GoRoute(
              path: RouteNames.doctorAppointmentsList,
              builder: (_, __) => const AppointmentsListPage(),
            ),
          ]),
          // Patients
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorPatients,
              builder: (_, __) => const PatientsListPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) =>
                      PatientDetailPage(patientId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          // Consultations
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorConsultations,
              builder: (_, __) => const ConsultationsPage(),
            ),
          ]),
          // Prescriptions
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorPrescriptions,
              builder: (_, __) => const PrescriptionsListPage(),
            ),
            GoRoute(
              path: RouteNames.doctorPrescriptionsTemplates,
              builder: (_, __) => const PrescriptionTemplatesPage(),
            ),
            GoRoute(
              path: RouteNames.doctorPrescriptionsNew,
              builder: (_, __) => const CreatePrescriptionPage(),
            ),
          ]),
          // Schedule
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorSchedule,
              builder: (_, __) => const SchedulePage(),
            ),
          ]),
          // Profile
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorProfile,
              builder: (_, __) => const DoctorProfilePage(),
            ),
          ]),
          // Settings
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorSettings,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Settings'),
            ),
          ]),
          // Notifications
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorNotifications,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Notifications'),
            ),
          ]),
        ],
      ),

      // ── Admin workspace ──────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AdminWorkspace(navigationShell: shell),
        branches: [
          // Dashboard
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminDashboard,
              builder: (_, __) => const AdminDashboardPage(),
            ),
          ]),
          // Queue
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminQueue,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Live Queue'),
            ),
          ]),
          // Appointments
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminAppointments,
              redirect: (_, __) => RouteNames.adminAppointmentsPending,
            ),
            GoRoute(
              path: RouteNames.adminAppointmentsPending,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Pending Appointments'),
            ),
            GoRoute(
              path: RouteNames.adminAppointmentsCalendar,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Appointments — Calendar'),
            ),
            GoRoute(
              path: RouteNames.adminAppointmentsList,
              builder: (_, __) => const ShellPlaceholderPage(title: 'All Appointments'),
            ),
          ]),
          // Doctors
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminDoctors,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Doctors'),
            ),
          ]),
          // Patients
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminPatients,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Patients'),
            ),
          ]),
          // Payments
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminPayments,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Payments'),
            ),
          ]),
          // Prescriptions
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminPrescriptions,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Prescriptions'),
            ),
          ]),
          // Analytics
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminAnalytics,
              redirect: (_, __) => RouteNames.adminAnalyticsDashboard,
            ),
            GoRoute(
              path: RouteNames.adminAnalyticsDashboard,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Analytics Overview'),
            ),
            GoRoute(
              path: RouteNames.adminAnalyticsRevenue,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Revenue Analytics'),
            ),
            GoRoute(
              path: RouteNames.adminAnalyticsDoctors,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Per-Doctor Analytics'),
            ),
            GoRoute(
              path: RouteNames.adminAnalyticsExport,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Export Analytics'),
            ),
          ]),
          // Staff & Admins
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminAdmins,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Staff & Admins'),
            ),
          ]),
          // Audit log
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminAuditLog,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Audit Log'),
            ),
          ]),
          // Settings
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminSettings,
              redirect: (_, __) => RouteNames.adminSettingsCenter,
            ),
            GoRoute(
              path: RouteNames.adminSettingsCenter,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Center Settings — General'),
            ),
            GoRoute(
              path: RouteNames.adminSettingsBranding,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Center Settings — Branding'),
            ),
            GoRoute(
              path: RouteNames.adminSettingsHours,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Center Settings — Working Hours'),
            ),
            GoRoute(
              path: RouteNames.adminSettingsBooking,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Center Settings — Booking Rules'),
            ),
          ]),
          // Profile
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminProfile,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Profile'),
            ),
          ]),
          // Notifications
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminNotifications,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Notifications'),
            ),
          ]),
        ],
      ),

      // ── SuperAdmin workspace ─────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => SuperAdminWorkspace(navigationShell: shell),
        branches: [
          // Dashboard
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminDashboard,
              builder: (_, __) => const SuperAdminDashboardPage(),
            ),
          ]),
          // Centers
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminCenters,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Health Centers'),
            ),
            GoRoute(
              path: RouteNames.superAdminCentersPending,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Centers — Pending Approval'),
            ),
            GoRoute(
              path: RouteNames.superAdminCentersSuspended,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Centers — Suspended'),
            ),
          ]),
          // Doctors
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminDoctors,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Doctors'),
            ),
            GoRoute(
              path: RouteNames.superAdminDoctorsPending,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Doctors — Pending Verification'),
            ),
          ]),
          // Users
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminUsers,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Users'),
            ),
          ]),
          // Subscriptions
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminSubscriptions,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Subscriptions'),
            ),
          ]),
          // Analytics
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminAnalytics,
              redirect: (_, __) => RouteNames.superAdminAnalyticsDashboard,
            ),
            GoRoute(
              path: RouteNames.superAdminAnalyticsDashboard,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Platform Analytics'),
            ),
            GoRoute(
              path: RouteNames.superAdminAnalyticsRevenue,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Revenue Analytics'),
            ),
            GoRoute(
              path: RouteNames.superAdminAnalyticsGrowth,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Growth Analytics'),
            ),
          ]),
          // Audit Log
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminAuditLog,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Audit Log'),
            ),
          ]),
          // Settings
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminSettings,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Platform Settings'),
            ),
          ]),
          // Profile
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminProfile,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Profile'),
            ),
          ]),
          // Notifications
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminNotifications,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Notifications'),
            ),
          ]),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final path = state.matchedLocation;
    const publicPaths = {
      RouteNames.splash,
      RouteNames.login,
      RouteNames.forgotPassword,
      RouteNames.resetPassword,
    };

    if (publicPaths.contains(path)) return null;
    if (!_ctx.isAuthenticated) return RouteNames.login;

    switch (_ctx.userType) {
      case UserType.doctor:
        if (!path.startsWith('/doctor')) return RouteNames.doctorDashboard;
      case UserType.admin:
        if (!path.startsWith('/admin')) return RouteNames.adminDashboard;
      case UserType.superAdmin:
        if (!path.startsWith('/super-admin')) return RouteNames.superAdminDashboard;
      case UserType.unknown:
        return RouteNames.login;
    }
    return null;
  }
}
