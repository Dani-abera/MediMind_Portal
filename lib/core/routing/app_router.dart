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
import '../../features/admin/presentation/pages/registration/admin_registration_status_page.dart';
import '../../features/admin/presentation/pages/registration/register_center_page.dart';
import '../../features/admin/admin_workspace.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admins/admins_list_page.dart';
import '../../features/admin/presentation/pages/appointments/all_page.dart';
import '../../features/admin/presentation/pages/appointments/calendar_page.dart';
import '../../features/admin/presentation/pages/appointments/pending_page.dart';
import '../../features/admin/presentation/pages/doctors/roster_page.dart';
import '../../features/admin/presentation/pages/patients/directory_page.dart';
import '../../features/admin/presentation/pages/patients/patient_detail_page.dart';
import '../../features/admin/presentation/pages/queue/live_queue_page.dart';
import '../../features/admin/analytics/analytics_dashboard_page.dart';
import '../../features/admin/analytics/revenue_page.dart';
import '../../features/admin/analytics/per_doctor_page.dart';
import '../../features/admin/analytics/export_wizard_page.dart';
import '../../features/admin/payments/ledger_page.dart';
import '../../features/admin/audit_log/audit_log_page.dart';
import '../../features/admin/center_settings/general_page.dart';
import '../../features/admin/center_settings/branding_page.dart';
import '../../features/admin/center_settings/hours_page.dart';
import '../../features/admin/center_settings/booking_rules_page.dart';
import '../../features/super_admin/super_admin_workspace.dart';
import '../../features/super_admin/presentation/pages/super_admin_dashboard_page.dart';
import '../../features/super_admin/presentation/pages/centers/centers_page.dart';
import '../../features/super_admin/presentation/pages/centers/center_detail_page.dart';
import '../../features/super_admin/presentation/pages/doctors/platform_doctors_page.dart';
import '../../features/super_admin/presentation/pages/users/platform_users_page.dart';
import '../../features/super_admin/presentation/pages/subscriptions/platform_subscriptions_page.dart';
import '../../features/super_admin/presentation/pages/analytics/platform_analytics_page.dart';
import '../../features/super_admin/presentation/pages/audit_log/global_audit_log_page.dart';
import '../../features/super_admin/presentation/pages/platform_settings/platform_settings_page.dart';
import 'route_names.dart';

class AppRouter {
  final UserContext _ctx;

  AppRouter(this._ctx);

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: _redirect,
    routes: [
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: RouteNames.forgotPassword, builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, state) => ResetPasswordPage(token: state.uri.queryParameters['token']),
      ),

      GoRoute(
        path: '/doctor/video-call/:id',
        builder: (_, state) =>
            VideoCallPage(consultationId: state.pathParameters['id']!),
      ),

      GoRoute(
        path: RouteNames.adminRegisterCenter,
        builder: (_, __) => const RegisterCenterPage(),
      ),
      GoRoute(
        path: RouteNames.adminPendingApproval,
        builder: (_, __) => const AdminRegistrationStatusPage(
          title: 'Pending Approval',
          message: 'Your center registration is currently under review by Super Admin.',
        ),
      ),
      GoRoute(
        path: RouteNames.adminCenterRejected,
        builder: (_, __) => const AdminRegistrationStatusPage(
          title: 'Registration Rejected',
          message: 'Your center registration has been rejected. Please contact support.',
        ),
      ),
      GoRoute(
        path: RouteNames.adminCenterSuspended,
        builder: (_, __) => const AdminRegistrationStatusPage(
          title: 'Account Suspended',
          message: 'Your healthcare center account has been suspended.',
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => DoctorWorkspace(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorDashboard,
              builder: (_, __) => const DoctorDashboardPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorQueue,
              builder: (_, __) => const QueuePage(),
            ),
          ]),
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
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorConsultations,
              builder: (_, __) => const ConsultationsPage(),
            ),
          ]),
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
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorSchedule,
              builder: (_, __) => const SchedulePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorProfile,
              builder: (_, __) => const DoctorProfilePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorSettings,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Settings'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorNotifications,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Notifications'),
            ),
          ]),
        ],
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AdminWorkspace(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminDashboard,
              builder: (_, __) => const AdminDashboardPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminQueue,
              builder: (_, __) => const LiveQueuePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminAppointments,
              redirect: (_, __) => RouteNames.adminAppointmentsPending,
            ),
            GoRoute(
              path: RouteNames.adminAppointmentsPending,
              builder: (_, __) => const PendingAppointmentsPage(),
            ),
            GoRoute(
              path: RouteNames.adminAppointmentsCalendar,
              builder: (_, __) => const AdminCalendarPage(),
            ),
            GoRoute(
              path: RouteNames.adminAppointmentsList,
              builder: (_, __) => const AllAppointmentsPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminDoctors,
              builder: (_, __) => const DoctorsRosterPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminPatients,
              builder: (_, __) => const PatientDirectoryPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) =>
                      AdminPatientDetailPage(patientId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminPayments,
              builder: (_, __) => const PaymentsLedgerPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminPrescriptions,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Prescriptions'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminAnalytics,
              redirect: (_, __) => RouteNames.adminAnalyticsDashboard,
            ),
            GoRoute(
              path: RouteNames.adminAnalyticsDashboard,
              builder: (_, __) => const AnalyticsDashboardPage(),
            ),
            GoRoute(
              path: RouteNames.adminAnalyticsRevenue,
              builder: (_, __) => const RevenuePage(),
            ),
            GoRoute(
              path: RouteNames.adminAnalyticsDoctors,
              builder: (_, __) => const PerDoctorAnalyticsPage(),
            ),
            GoRoute(
              path: RouteNames.adminAnalyticsExport,
              builder: (_, __) => const ExportWizardPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminAdmins,
              builder: (_, __) => const AdminsListPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminAuditLog,
              builder: (_, __) => const AuditLogPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminSettings,
              redirect: (_, __) => RouteNames.adminSettingsCenter,
            ),
            GoRoute(
              path: RouteNames.adminSettingsCenter,
              builder: (_, __) => const CenterGeneralPage(),
            ),
            GoRoute(
              path: RouteNames.adminSettingsBranding,
              builder: (_, __) => const CenterBrandingPage(),
            ),
            GoRoute(
              path: RouteNames.adminSettingsHours,
              builder: (_, __) => const CenterHoursPage(),
            ),
            GoRoute(
              path: RouteNames.adminSettingsBooking,
              builder: (_, __) => const BookingRulesPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminProfile,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Profile'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminNotifications,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Notifications'),
            ),
          ]),
        ],
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => SuperAdminWorkspace(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminDashboard,
              builder: (_, __) => const SuperAdminDashboardPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminCenters,
              builder: (_, __) => const CentersPage(initialTab: 0),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) =>
                      CenterDetailPage(centerId: state.pathParameters['id']!),
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.superAdminCentersPending,
              builder: (_, __) => const CentersPage(initialTab: 1),
            ),
            GoRoute(
              path: RouteNames.superAdminCentersSuspended,
              builder: (_, __) => const CentersPage(initialTab: 3),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminDoctors,
              builder: (_, __) => const PlatformDoctorsPage(),
            ),
            GoRoute(
              path: RouteNames.superAdminDoctorsPending,
              builder: (_, __) => const PlatformDoctorsPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminUsers,
              builder: (_, __) => const PlatformUsersPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminSubscriptions,
              builder: (_, __) => const PlatformSubscriptionsPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminAnalytics,
              redirect: (_, __) => RouteNames.superAdminAnalyticsDashboard,
            ),
            GoRoute(
              path: RouteNames.superAdminAnalyticsDashboard,
              builder: (_, __) => const PlatformAnalyticsPage(initialTab: 0),
            ),
            GoRoute(
              path: RouteNames.superAdminAnalyticsRevenue,
              builder: (_, __) => const PlatformAnalyticsPage(initialTab: 1),
            ),
            GoRoute(
              path: RouteNames.superAdminAnalyticsGrowth,
              builder: (_, __) => const PlatformAnalyticsPage(initialTab: 2),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminAuditLog,
              builder: (_, __) => const GlobalAuditLogPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminSettings,
              builder: (_, __) => const PlatformSettingsPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminProfile,
              builder: (_, __) => const ShellPlaceholderPage(title: 'Profile'),
            ),
          ]),
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
        return null;
      case UserType.admin:
        final status = _ctx.centerStatus;
        if (_ctx.centerId == null) {
          if (path != RouteNames.adminRegisterCenter) return RouteNames.adminRegisterCenter;
        } else if (status == 'PendingApproval') {
          if (path != RouteNames.adminPendingApproval) return RouteNames.adminPendingApproval;
        } else if (status == 'Rejected') {
          if (path != RouteNames.adminCenterRejected) return RouteNames.adminCenterRejected;
        } else if (status == 'Suspended') {
          if (path != RouteNames.adminCenterSuspended) return RouteNames.adminCenterSuspended;
        } else {
          if (!path.startsWith('/admin') ||
              path == RouteNames.adminRegisterCenter ||
              path == RouteNames.adminPendingApproval ||
              path == RouteNames.adminCenterRejected ||
              path == RouteNames.adminCenterSuspended) {
            return RouteNames.adminDashboard;
          }
        }
        return null;
      case UserType.superAdmin:
        if (!path.startsWith('/super-admin')) return RouteNames.superAdminDashboard;
        return null;
      case UserType.unknown:
        return RouteNames.login;
    }
  }
}
