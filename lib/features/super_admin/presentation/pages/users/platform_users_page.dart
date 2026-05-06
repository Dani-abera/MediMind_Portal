import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../domain/entities/platform_user.dart';
import '../../bloc/users/platform_users_bloc.dart';

class PlatformUsersPage extends StatelessWidget {
  const PlatformUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlatformUsersBloc>()..add(const PlatformUsersStarted()),
      child: const _UsersView(),
    );
  }
}

class _UsersView extends StatelessWidget {
  const _UsersView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlatformUsersBloc, PlatformUsersState>(
      listener: (ctx, state) {
        if (state is PlatformUsersActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is PlatformUsersActionError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Users',
            subtitle: 'Platform-wide user management',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: () => context.read<PlatformUsersBloc>().add(const PlatformUsersRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<PlatformUsersBloc, PlatformUsersState>(
              builder: (ctx, state) {
                final users = state is PlatformUsersLoaded ? state.users : <PlatformUser>[];
                final total = state is PlatformUsersLoaded ? state.total : 0;
                final page = state is PlatformUsersLoaded ? state.page : 1;
                const pageSize = 20;
                final isLoading = state is PlatformUsersLoading;

                return AppDataTable<PlatformUser>(
                  rows: users,
                  isLoading: isLoading,
                  selectable: false,
                  emptyMessage: 'No users found',
                  pagination: PaginationConfig(
                    page: page,
                    pageSize: pageSize,
                    total: total,
                    onPageChanged: (p) => ctx.read<PlatformUsersBloc>().add(PlatformUsersPageChanged(p)),
                    onPageSizeChanged: (_) {},
                  ),
                  rowActionsBuilder: (user) => _UserActions(user: user),
                  columns: [
                    DataTableColumn(
                      label: 'Name',
                      builder: (u) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(u.fullName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          Text(u.email, style: AppTypography.caption.copyWith(color: AppColors.neutral400)),
                        ],
                      ),
                    ),
                    DataTableColumn(
                      label: 'Type',
                      width: 90,
                      builder: (u) => Text(u.userType, style: AppTypography.bodySmall),
                    ),
                    DataTableColumn(
                      label: 'Status',
                      width: 90,
                      builder: (u) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: (u.status == 'active' ? AppColors.success : AppColors.danger).withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          u.status,
                          style: TextStyle(
                            fontSize: 11,
                            color: u.status == 'active' ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataTableColumn(
                      label: 'Joined',
                      width: 100,
                      builder: (u) => Text(
                        DateFormat('MMM d, y').format(u.createdAt),
                        style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                      ),
                    ),
                    DataTableColumn(
                      label: 'Last Login',
                      width: 110,
                      builder: (u) => Text(
                        u.lastLoginAt != null ? DateFormat('MMM d, y').format(u.lastLoginAt!) : 'Never',
                        style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserActions extends StatelessWidget {
  final PlatformUser user;
  const _UserActions({required this.user});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      itemBuilder: (_) => [
        if (user.status == 'active')
          const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
        if (user.status == 'suspended')
          const PopupMenuItem(value: 'reactivate', child: Text('Reactivate')),
        const PopupMenuItem(value: 'force_logout', child: Text('Force Logout')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (action) async {
        switch (action) {
          case 'suspend':
            final confirmed = await ConfirmDialog.show(
              context,
              title: 'Suspend User',
              message: 'Suspend ${user.fullName}?',
              confirmLabel: 'Suspend',
              isDangerous: true,
            );
            if (confirmed && context.mounted) {
              context.read<PlatformUsersBloc>().add(UserSuspendRequested(user.id, 'Suspended by admin'));
            }
          case 'reactivate':
            if (context.mounted) {
              context.read<PlatformUsersBloc>().add(UserReactivateRequested(user.id));
            }
          case 'force_logout':
            if (context.mounted) {
              context.read<PlatformUsersBloc>().add(UserForceLogoutRequested(user.id));
            }
          case 'delete':
            final confirmed = await ConfirmDialog.show(
              context,
              title: 'Delete User',
              message: 'Permanently delete ${user.fullName}? This cannot be undone.',
              confirmLabel: 'Delete',
              isDangerous: true,
            );
            if (confirmed && context.mounted) {
              context.read<PlatformUsersBloc>().add(UserDeleteRequested(user.id));
            }
        }
      },
    );
  }
}
