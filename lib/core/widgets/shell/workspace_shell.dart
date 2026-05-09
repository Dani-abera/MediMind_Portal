import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'bloc/shell_bloc.dart';
import 'bloc/shell_event.dart';
import 'bloc/shell_state.dart';
import 'env_badge.dart';
import 'sidebar.dart';
import 'top_bar.dart';
import '../../di/service_locator.dart';
import '../../routing/route_names.dart';
import '../../routing/sidebar_configs.dart';
import '../../services/inactivity_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_cubit.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../shared/blocs/notification_bloc.dart';

export 'bloc/shell_event.dart' show AppConnectionStatus;

enum WorkspaceBranding { doctor, admin, superAdmin }

class WorkspaceShell extends StatefulWidget {
  final WorkspaceBranding branding;
  final StatefulNavigationShell navigationShell;

  const WorkspaceShell({
    super.key,
    required this.branding,
    required this.navigationShell,
  });

  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  late final ShellBloc _shellBloc;
  late final NotificationBloc _notifBloc;
  final FocusNode _keyboardFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _shellBloc = sl<ShellBloc>();
    _notifBloc = sl<NotificationBloc>()
      ..add(const NotificationStarted());
    _setupInactivityLogout();
  }

  @override
  void dispose() {
    _keyboardFocus.dispose();
    super.dispose();
  }

  void _setupInactivityLogout() {
    sl<InactivityService>().configure(
      timeout: const Duration(minutes: 30),
      onTimeout: () {
        if (!mounted) return;
        sl<InactivityService>().dispose();
        context.read<AuthBloc>().add(const AuthLogoutRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out due to inactivity')),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = GoRouterState.of(context).matchedLocation;
    if (route != _shellBloc.state.currentRoute) {
      _shellBloc.add(RouteChanged(route));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _shellBloc),
        BlocProvider.value(value: _notifBloc),
      ],
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthUnauthenticated) {
            ctx.go(RouteNames.login);
          }
        },
        builder: (ctx, authState) => Stack(
          children: [
            BlocBuilder<ShellBloc, ShellState>(
              builder: (ctx, shell) => InactivityDetector(
                child: Scaffold(
                  body: KeyboardListener(
                    focusNode: _keyboardFocus,
                    autofocus: true,
                    onKeyEvent: (e) => _onKey(e, ctx),
                    child: Row(
                      children: [
                        Sidebar(
                          items: cfg.items,
                          collapsed: shell.sidebarCollapsed,
                          onToggleCollapse: () => _shellBloc.add(const SidebarToggled()),
                          workspaceName: cfg.name,
                          accentColor: cfg.accent,
                          backgroundTint: cfg.backgroundTint,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              BlocBuilder<NotificationBloc, NotificationState>(
                                builder: (_, ns) => TopBar(
                                  breadcrumbs: shell.breadcrumbs,
                                  connectionStatus: shell.connectionStatus,
                                  unreadNotificationCount: ns.unreadCount,
                                  notifications: ns.recent,
                                  notificationsRoute: _notifRoute,
                                  profileRoute: _profileRoute,
                                  settingsRoute: _settingsRoute,
                                  onToggleTheme: () => ctx.read<ThemeCubit>().toggle(),
                                  onLogout: () {
                                    ctx.read<AuthBloc>().add(const AuthLogoutRequested());
                                  },
                                  trailing: cfg.trailingExtra,
                                ),
                              ),
                              Expanded(child: widget.navigationShell),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (authState is AuthLoading)
              Container(
                color: Colors.black.withAlpha(100),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onKey(KeyEvent event, BuildContext ctx) {
    if (event is! KeyDownEvent) return;
    final ctrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyB) {
      _shellBloc.add(const SidebarToggled());
    }
  }

  _ShellConfig get _config {
    switch (widget.branding) {
      case WorkspaceBranding.doctor:
        return _ShellConfig(
          name: 'Doctor Portal',
          accent: AppColors.primary,
          items: SidebarConfigs.doctor,
        );
      case WorkspaceBranding.admin:
        return _ShellConfig(
          name: 'Admin Portal',
          accent: AppColors.info,
          items: SidebarConfigs.admin,
          trailingExtra: _AddAppointmentButton(),
        );
      case WorkspaceBranding.superAdmin:
        return _ShellConfig(
          name: 'Platform Admin',
          accent: AppColors.danger,
          backgroundTint: AppColors.danger,
          items: SidebarConfigs.superAdmin,
          trailingExtra: const EnvBadge(),
        );
    }
  }

  String get _profileRoute => switch (widget.branding) {
        WorkspaceBranding.doctor => RouteNames.doctorProfile,
        WorkspaceBranding.admin => RouteNames.adminProfile,
        WorkspaceBranding.superAdmin => RouteNames.superAdminProfile,
      };

  String get _settingsRoute => switch (widget.branding) {
        WorkspaceBranding.doctor => RouteNames.doctorSettings,
        WorkspaceBranding.admin => RouteNames.adminSettingsCenter,
        WorkspaceBranding.superAdmin => RouteNames.superAdminSettings,
      };

  String get _notifRoute => switch (widget.branding) {
        WorkspaceBranding.doctor => RouteNames.doctorNotifications,
        WorkspaceBranding.admin => RouteNames.adminNotifications,
        WorkspaceBranding.superAdmin => RouteNames.superAdminNotifications,
      };
}

class _ShellConfig {
  final String name;
  final Color accent;
  final Color? backgroundTint;
  final List<SidebarItem> items;
  final Widget? trailingExtra;

  const _ShellConfig({
    required this.name,
    required this.accent,
    required this.items,
    this.backgroundTint,
    this.trailingExtra,
  });
}

class _AddAppointmentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => context.go(RouteNames.adminAppointmentsPending),
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add Appointment'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.info,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        minimumSize: const Size(0, 36),
      ),
    );
  }
}
