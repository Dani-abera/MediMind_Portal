import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../command_palette/command_palette.dart';

class TopBar extends StatelessWidget {
  final List<String> breadcrumbs;
  final bool isRealtimeConnected;
  final int notificationCount;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final VoidCallback onLogout;
  final Widget? trailing;

  const TopBar({
    super.key,
    this.breadcrumbs = const [],
    this.isRealtimeConnected = false,
    this.notificationCount = 0,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onNotifications,
    required this.onProfile,
    required this.onSettings,
    required this.onLogout,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
            child: _Breadcrumb(crumbs: breadcrumbs),
          ),
          // Search
          Expanded(
            flex: 2,
            child: _SearchBar(onTap: () => CommandPalette.show(context)),
          ),
          // Right actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ConnectionDot(connected: isRealtimeConnected),
              const SizedBox(width: 8),
              _NotificationButton(
                count: notificationCount,
                onTap: onNotifications,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: FaIcon(
                  isDarkMode
                      ? FontAwesomeIcons.sun
                      : FontAwesomeIcons.moon,
                  size: 16,
                  color: AppColors.neutral500,
                ),
                tooltip: isDarkMode ? 'Light mode' : 'Dark mode',
                onPressed: onToggleTheme,
              ),
              const SizedBox(width: 4),
              _UserAvatarDropdown(
                onProfile: onProfile,
                onSettings: onSettings,
                onLogout: onLogout,
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  final List<String> crumbs;
  const _Breadcrumb({required this.crumbs});

  @override
  Widget build(BuildContext context) {
    if (crumbs.isEmpty) return const SizedBox.shrink();

    return Row(
      children: crumbs
          .asMap()
          .entries
          .expand((entry) {
            final isLast = entry.key == crumbs.length - 1;
            return [
              Text(
                entry.value,
                style: AppTypography.bodySmall.copyWith(
                  color: isLast
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.neutral400,
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 10,
                    color: AppColors.neutral300,
                  ),
                ),
            ];
          })
          .toList(),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

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
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral400,
                ),
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

class _ConnectionDot extends StatelessWidget {
  final bool connected;
  const _ConnectionDot({required this.connected});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: connected ? 'Realtime: Connected' : 'Realtime: Disconnected',
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: connected ? AppColors.success : AppColors.neutral300,
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _NotificationButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.bell,
              size: 16, color: AppColors.neutral500),
          onPressed: onTap,
          tooltip: 'Notifications',
        ),
        if (count > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: AppTypography.caption.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _UserAvatarDropdown extends StatelessWidget {
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _UserAvatarDropdown({
    required this.onProfile,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      child: CircleAvatar(
        radius: 15,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          'U',
          style: AppTypography.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      itemBuilder: (_) => [
        _menuItem('profile', FontAwesomeIcons.user, 'Profile'),
        _menuItem('settings', FontAwesomeIcons.gear, 'Settings'),
        const PopupMenuDivider(),
        _menuItem('logout', FontAwesomeIcons.rightFromBracket, 'Logout',
            isDestructive: true),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            onProfile();
          case 'settings':
            onSettings();
          case 'logout':
            onLogout();
        }
      },
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? AppColors.danger : AppColors.neutral700;
    return PopupMenuItem(
      value: value,
      height: 36,
      child: Row(
        children: [
          FaIcon(icon, size: 13, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: AppTypography.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
