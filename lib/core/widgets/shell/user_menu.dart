import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/domain/entities/admin_user.dart';
import '../../../features/auth/domain/entities/doctor_user.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../features/auth/presentation/widgets/change_password_dialog.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class UserMenu extends StatelessWidget {
  final String profileRoute;
  final String settingsRoute;
  final List<PopupMenuEntry<String>>? extraItems;

  const UserMenu({
    super.key,
    required this.profileRoute,
    required this.settingsRoute,
    this.extraItems,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (_, curr) =>
          curr is AuthAuthenticated || curr is AuthUnauthenticated,
      builder: (ctx, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final name = user?.fullName ?? 'User';
        final email = user?.email ?? '';
        final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

        final String roleLabel;
        if (user is DoctorUser) {
          roleLabel = user.specialization ?? 'Doctor';
        } else if (user is AdminUser) {
          roleLabel = 'Admin';
        } else {
          roleLabel = 'Platform Admin';
        }

        return PopupMenuButton<String>(
          offset: const Offset(0, 48),
          child: _UserChip(
            name: name,
            initials: initials,
            roleLabel: roleLabel,
            avatarUrl: user?.avatarUrl,
          ),
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              enabled: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: _UserHeader(
                name: name,
                email: email,
                roleLabel: roleLabel,
                initials: initials,
                avatarUrl: user?.avatarUrl,
              ),
            ),
            const PopupMenuDivider(),
            _menuItem('profile', FontAwesomeIcons.user, 'Profile'),
            _menuItem('settings', FontAwesomeIcons.gear, 'Settings'),
            if (user is! DoctorUser)
              _menuItem(
                'change_password',
                FontAwesomeIcons.lock,
                'Change Password',
              ),
            _menuItem(
              'help',
              FontAwesomeIcons.circleQuestion,
              'Help & Support',
            ),
            if (extraItems != null) ...extraItems!,
            const PopupMenuDivider(),
            _menuItem(
              'logout',
              FontAwesomeIcons.rightFromBracket,
              'Logout',
              isDestructive: true,
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'profile':
                context.go(profileRoute);
              case 'settings':
                context.go(settingsRoute);
              case 'change_password':
                ChangePasswordDialog.show(context);
              case 'logout':
                _confirmLogout(context, ctx);
            }
          },
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, BuildContext blocCtx) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () {
              Navigator.of(context).pop();
              blocCtx.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.danger : AppColors.neutral700;
    return PopupMenuItem<String>(
      value: value,
      height: 36,
      child: Row(
        children: [
          FaIcon(icon, size: 13, color: color),
          const SizedBox(width: 10),
          Text(label, style: AppTypography.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  final String name;
  final String initials;
  final String roleLabel;
  final String? avatarUrl;

  const _UserChip({
    required this.name,
    required this.initials,
    required this.roleLabel,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Text(
                    initials,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (roleLabel.isNotEmpty)
                Text(
                  roleLabel,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
          const FaIcon(
            FontAwesomeIcons.chevronDown,
            size: 10,
            color: AppColors.neutral400,
          ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final String name;
  final String email;
  final String roleLabel;
  final String initials;
  final String? avatarUrl;

  const _UserHeader({
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.initials,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Text(
                  initials,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(80),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  roleLabel,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: AppTypography.caption.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
