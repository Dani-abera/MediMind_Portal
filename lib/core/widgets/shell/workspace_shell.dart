import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'sidebar.dart';
import 'top_bar.dart';
import '../../theme/app_colors.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../routing/route_names.dart';
import '../../routing/sidebar_configs.dart';
import '../../di/service_locator.dart';

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
  bool _sidebarCollapsed = false;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final config = _brandingConfig;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Row(
        children: [
          Sidebar(
            items: config.items,
            collapsed: _sidebarCollapsed,
            onToggleCollapse: () =>
                setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            workspaceName: config.name,
            accentColor: config.color,
          ),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  breadcrumbs: _buildBreadcrumbs(context),
                  isDarkMode: _isDarkMode,
                  onToggleTheme: () =>
                      setState(() => _isDarkMode = !_isDarkMode),
                  onNotifications: () {},
                  onProfile: () => context.go(_profileRoute),
                  onSettings: () => context.go(_settingsRoute),
                  onLogout: _handleLogout,
                ),
                Expanded(child: widget.navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final ctrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyB) {
      setState(() => _sidebarCollapsed = !_sidebarCollapsed);
    }
  }

  List<String> _buildBreadcrumbs(BuildContext context) {
    final path = GoRouterState.of(context).matchedLocation;
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    return parts.map((p) => p.replaceAll('-', ' ').capitalize()).toList();
  }

  void _handleLogout() {
    sl<AuthBloc>().add(const AuthLogoutRequested());
    context.go(RouteNames.login);
  }

  _BrandingConfig get _brandingConfig {
    switch (widget.branding) {
      case WorkspaceBranding.doctor:
        return _BrandingConfig(
          name: 'Doctor Portal',
          color: AppColors.primary,
          items: SidebarConfigs.doctor,
        );
      case WorkspaceBranding.admin:
        return _BrandingConfig(
          name: 'Admin Portal',
          color: AppColors.info,
          items: SidebarConfigs.admin,
        );
      case WorkspaceBranding.superAdmin:
        return _BrandingConfig(
          name: 'SuperAdmin',
          color: AppColors.warning,
          items: SidebarConfigs.superAdmin,
        );
    }
  }

  String get _profileRoute {
    switch (widget.branding) {
      case WorkspaceBranding.doctor:
        return RouteNames.doctorProfile;
      case WorkspaceBranding.admin:
        return RouteNames.adminProfile;
      case WorkspaceBranding.superAdmin:
        return RouteNames.superAdminProfile;
    }
  }

  String get _settingsRoute {
    switch (widget.branding) {
      case WorkspaceBranding.doctor:
        return RouteNames.doctorSettings;
      case WorkspaceBranding.admin:
        return RouteNames.adminSettings;
      case WorkspaceBranding.superAdmin:
        return RouteNames.superAdminSettings;
    }
  }
}

class _BrandingConfig {
  final String name;
  final Color color;
  final List<SidebarItem> items;
  const _BrandingConfig({
    required this.name,
    required this.color,
    required this.items,
  });
}

extension _StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
