import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/user_context.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../../../core/widgets/status_badges/status_badge.dart';
import '../../../domain/entities/admin_staff.dart';
import '../../bloc/admins/admin_staff_bloc.dart';

class AdminsListPage extends StatelessWidget {
  const AdminsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminStaffBloc>()
        ..add(AdminStaffStarted(UserContext().centerId ?? '')),
      child: const _AdminsListView(),
    );
  }
}

class _AdminsListView extends StatelessWidget {
  const _AdminsListView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminStaffBloc, AdminStaffState>(
      listener: (ctx, state) {
        if (state is AdminStaffError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        } else if (state is AdminStaffActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Staff & Admins',
            subtitle: 'Manage admin accounts for this center',
            actions: [
              AppButton.primary(
                label: 'Add Admin',
                icon: FontAwesomeIcons.userPlus,
                onPressed: () => _AddAdminDialog.show(context),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Refresh',
                onPressed: () => context.read<AdminStaffBloc>().add(const AdminStaffRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Expanded(child: _AdminsTable()),
        ],
      ),
    );
  }
}

class _AdminsTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminStaffBloc, AdminStaffState>(
      builder: (ctx, state) {
        final staff = state is AdminStaffLoaded ? state.staff : <AdminStaff>[];
        final currentUserId = state is AdminStaffLoaded ? state.currentUserId : '';
        final isLoading = state is AdminStaffLoading ||
            state is AdminStaffInitial ||
            state is AdminStaffActionInProgress;

        return AppDataTable<AdminStaff>(
          rows: staff,
          isLoading: isLoading,
          emptyMessage: 'No admin accounts found',
          selectable: false,
          columns: [
            DataTableColumn(
              label: 'Admin',
              builder: (a) => Row(
                children: [
                  _avatar(a),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              a.fullName,
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (a.id == currentUserId) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: AppRadius.radiusFull,
                                ),
                                child: Text(
                                  'You',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          a.email,
                          style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DataTableColumn(
              label: 'Phone',
              width: 130,
              builder: (a) => Text(
                a.phone ?? '—',
                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
              ),
            ),
            DataTableColumn(
              label: 'Role',
              width: 110,
              builder: (a) => _roleBadge(a.role),
            ),
            DataTableColumn(
              label: 'Status',
              width: 90,
              builder: (a) => a.status == AdminStatus.active
                  ? const StatusBadge(label: 'Active', status: BadgeStatus.active)
                  : const StatusBadge(label: 'Suspended', status: BadgeStatus.suspended),
            ),
            DataTableColumn(
              label: 'Last Login',
              width: 130,
              builder: (a) => Text(
                a.lastLogin != null
                    ? DateFormat('MMM d, yyyy').format(a.lastLogin!)
                    : 'Never',
                style: AppTypography.caption.copyWith(color: AppColors.neutral500),
              ),
            ),
          ],
          rowActionsBuilder: (a) => _AdminRowActions(admin: a, currentUserId: currentUserId),
        );
      },
    );
  }

  Widget _avatar(AdminStaff a) {
    final initials = a.fullName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.primaryLight.withAlpha(80),
      child: Text(
        initials,
        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
      ),
    );
  }

  Widget _roleBadge(AdminRole role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: role == AdminRole.admin
            ? AppColors.primaryLight.withAlpha(60)
            : AppColors.neutral100,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(
        role.label,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: role == AdminRole.admin ? AppColors.primary : AppColors.neutral600,
        ),
      ),
    );
  }
}

class _AdminRowActions extends StatelessWidget {
  final AdminStaff admin;
  final String currentUserId;
  const _AdminRowActions({required this.admin, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isSelf = admin.id == currentUserId;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16, color: AppColors.neutral400),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'deactivate',
          enabled: !isSelf && admin.status == AdminStatus.active,
          child: Text(
            isSelf ? 'Cannot deactivate yourself' : 'Deactivate',
            style: TextStyle(
              color: isSelf ? AppColors.neutral400 : AppColors.danger,
            ),
          ),
        ),
      ],
      onSelected: (v) async {
        if (v == 'deactivate') {
          final ok = await ConfirmDialog.show(
            context,
            title: 'Deactivate Admin',
            message: 'Deactivate ${admin.fullName}? They will lose access immediately.',
            confirmLabel: 'Deactivate',
            isDangerous: true,
          );
          if (ok && context.mounted) {
            context.read<AdminStaffBloc>().add(AdminDeactivatedFromStaff(admin.id));
          }
        }
      },
    );
  }
}

class _AddAdminDialog extends StatefulWidget {
  const _AddAdminDialog._();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AdminStaffBloc>(),
        child: const _AddAdminDialog._(),
      ),
    );
  }

  @override
  State<_AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<_AddAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  AdminRole _role = AdminRole.admin;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminStaffBloc, AdminStaffState>(
      listener: (ctx, state) {
        if (state is AdminStaffActionSuccess) {
          Navigator.of(ctx).pop();
        } else if (state is AdminStaffError) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        } else if (state is AdminStaffActionInProgress) {
          setState(() => _submitting = true);
        }
      },
      child: AlertDialog(
        title: const Text('Add Admin / Staff'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'An invitation email will be sent to the new admin to complete registration.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                ),
                const SizedBox(height: AppSpacing.base),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone (optional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.base),
                Row(
                  children: [
                    Text('Role:', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(width: AppSpacing.base),
                    ...AdminRole.values.map((r) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(r.label),
                            selected: _role == r,
                            onSelected: (_) => setState(() => _role = r),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          AppButton.primary(
            label: 'Send Invitation',
            icon: FontAwesomeIcons.paperPlane,
            isLoading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AdminStaffBloc>().add(AdminAddedToStaff(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          role: _role,
        ));
  }
}
