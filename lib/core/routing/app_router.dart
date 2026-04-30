import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/user_context.dart';
import '../widgets/shell/workspace_shell.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/doctor/presentation/pages/doctor_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
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
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, state) => ResetPasswordPage(
          token: state.uri.queryParameters['token'],
        ),
      ),
      // Doctor shell
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, shell) => WorkspaceShell(
          branding: WorkspaceBranding.doctor,
          navigationShell: shell,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorDashboard,
              builder: (_, __) => const DoctorDashboardPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorAppointments,
              redirect: (_, __) => RouteNames.doctorAppointmentsPending,
            ),
            GoRoute(
              path: RouteNames.doctorAppointmentsPending,
              builder: (_, __) => const _PlaceholderPage('Appointments / Pending'),
            ),
            GoRoute(
              path: RouteNames.doctorAppointmentsCalendar,
              builder: (_, __) => const _PlaceholderPage('Appointments / Calendar'),
            ),
            GoRoute(
              path: RouteNames.doctorAppointmentsAll,
              builder: (_, __) => const _PlaceholderPage('Appointments / All'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorPatients,
              builder: (_, __) => const _PlaceholderPage('Patients'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorQueue,
              builder: (_, __) => const _PlaceholderPage('Queue'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.doctorSettings,
              builder: (_, __) => const _PlaceholderPage('Settings'),
            ),
          ]),
        ],
      ),
      // Admin shell
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, shell) => WorkspaceShell(
          branding: WorkspaceBranding.admin,
          navigationShell: shell,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminDashboard,
              builder: (_, __) => const AdminDashboardPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminDoctors,
              builder: (_, __) => const _PlaceholderPage('Doctors'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminAppointments,
              redirect: (_, __) => RouteNames.adminAppointmentsPending,
            ),
            GoRoute(
              path: RouteNames.adminAppointmentsPending,
              builder: (_, __) => const _PlaceholderPage('Appointments / Pending'),
            ),
            GoRoute(
              path: RouteNames.adminAppointmentsAll,
              builder: (_, __) => const _PlaceholderPage('Appointments / All'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminQueue,
              builder: (_, __) => const _PlaceholderPage('Queue'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminPatients,
              builder: (_, __) => const _PlaceholderPage('Patients'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminReports,
              builder: (_, __) => const _PlaceholderPage('Reports'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminSettings,
              builder: (_, __) => const _PlaceholderPage('Settings'),
            ),
          ]),
        ],
      ),
      // SuperAdmin shell
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, shell) => WorkspaceShell(
          branding: WorkspaceBranding.superAdmin,
          navigationShell: shell,
        ),
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
              builder: (_, __) => const _PlaceholderPage('Centers'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminDoctors,
              builder: (_, __) => const _PlaceholderPage('Doctors'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminSubscriptions,
              builder: (_, __) => const _PlaceholderPage('Subscriptions'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminAnalytics,
              builder: (_, __) => const _PlaceholderPage('Analytics'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.superAdminSettings,
              builder: (_, __) => const _PlaceholderPage('Settings'),
            ),
          ]),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final path = state.matchedLocation;
    final publicPaths = {
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

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
