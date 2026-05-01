import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../command_palette/command_palette.dart';
import 'bloc/shell_state.dart';
import 'breadcrumb_bar.dart';
import 'connection_status.dart';
import 'notification_bell.dart';
import 'user_menu.dart';
import 'workspace_shell.dart';

class TopBar extends StatelessWidget {
  final List<BreadcrumbSegment> breadcrumbs;
  final AppConnectionStatus connectionStatus;
  final int unreadNotificationCount;
  final List<Map<String, dynamic>> notifications;
  final String notificationsRoute;
  final String profileRoute;
  final String settingsRoute;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  final Widget? trailing;
  // branding is needed to know which workspace we're in
  final WorkspaceBranding? branding;

  const TopBar({
    super.key,
    this.breadcrumbs = const [],
    this.connectionStatus = AppConnectionStatus.offline,
    this.unreadNotificationCount = 0,
    this.notifications = const [],
    required this.notificationsRoute,
    required this.profileRoute,
    required this.settingsRoute,
    required this.onToggleTheme,
    required this.onLogout,
    this.trailing,
    this.branding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: AppSpacing.topBarHeight,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Breadcrumb
          Expanded(
            flex: 2,
            child: BreadcrumbBar(segments: breadcrumbs),
          ),
          // Search bar
          Expanded(
            flex: 2,
            child: _SearchHint(
              onTap: () => CommandPalette.show(context),
            ),
          ),
          // Right actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 8),
              ],
              ConnectionStatusDot(status: connectionStatus),
              const SizedBox(width: 8),
              NotificationBell(
                unreadCount: unreadNotificationCount,
                notifications: notifications,
                viewAllRoute: notificationsRoute,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: FaIcon(
                  isDark ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
                  size: 16,
                  color: AppColors.neutral500,
                ),
                tooltip: isDark ? 'Light mode' : 'Dark mode',
                onPressed: onToggleTheme,
              ),
              const SizedBox(width: 4),
              UserMenu(
                profileRoute: profileRoute,
                settingsRoute: settingsRoute,
                extraItems: branding == WorkspaceBranding.superAdmin
                    ? [
                        PopupMenuItem<String>(
                          value: 'readonly',
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.eye,
                                  size: 13, color: AppColors.neutral700),
                              const SizedBox(width: 10),
                              Text('Switch to read-only mode',
                                  style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                      ]
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.neutral200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            const FaIcon(FontAwesomeIcons.magnifyingGlass,
                size: 13, color: AppColors.neutral400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search... (Ctrl+K)',
                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '⌘K',
                style: AppTypography.caption.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
